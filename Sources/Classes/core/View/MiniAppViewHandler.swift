import Foundation
import WebKit

// swiftlint:disable file_length

// MARK: - MiniAppViewHandler
class MiniAppViewHandler: NSObject {

    internal var webView: WKWebView?

    internal let miniAppClient: MiniAppClient
    internal let miniAppDownloader: MiniAppDownloader
    internal let miniAppStatus: MiniAppStatus
    internal let manifestDownloader: ManifestDownloader
    internal let miniAppInfoFetcher: MiniAppInfoFetcher
    internal let miniAppManifestStorage: MAManifestStorage
    internal var metaDataDownloader: MetaDataDownloader
    internal var miniAppPermissionStorage: MiniAppPermissionsStorage
    internal let secureStorage: MiniAppSecureStorage

    var appId: String
    var version: String?
    var queryParams: String?
    weak var messageInterface: MiniAppMessageDelegate?
    internal var projectId: String?
    internal var analyticsConfig: [MAAnalyticsConfig]?

    // -
    internal var miniAppURL: URL?
    internal var adsDisplayer: AdMobDisplayer?
    internal var messageBodies: [String] = []

    internal var navBar: (UIView & MiniAppNavigationDelegate)?
    internal var navBarVisibility: MiniAppNavigationVisibility = .never
    internal var isNavBarCustom = false

    internal var supportedMiniAppOrientation: UIInterfaceOrientationMask = .portrait

    internal var initialLoadCallback: ((Bool) -> Void)?
    internal var closeAlertInfo: CloseAlertInfo?
    internal weak var navigationDelegate: MiniAppNavigationDelegate?

    internal var onExternalWebviewResponse: ((URL) -> Void)?
    internal var onExternalWebviewClose: ((URL) -> Void)?

    var canGoBackObservation: NSKeyValueObservation?
    var canGoForwardObservation: NSKeyValueObservation?

    internal var shouldAutoLoadSecureStorage: Bool = false

    init(
        config: MiniAppNewConfig,
        appId: String,
        version: String? = nil,
        queryParams: String? = nil
    ) {
        manifestDownloader = ManifestDownloader()
        miniAppStatus = MiniAppStatus()
        miniAppInfoFetcher = MiniAppInfoFetcher()
        miniAppManifestStorage = MAManifestStorage()
        metaDataDownloader = MetaDataDownloader()
        miniAppPermissionStorage = MiniAppPermissionsStorage()
        secureStorage = MiniAppSecureStorage(appId: appId, storageMaxSizeInBytes: 2_000_000)

        miniAppClient = MiniAppClient(
            baseUrl: config.config?.baseUrl,
            rasProjectId: config.config?.rasProjectId,
            subscriptionKey: config.config?.subscriptionKey,
            hostAppVersion: config.config?.hostAppVersion,
            isPreviewMode: config.config?.isPreviewMode
        )

        adsDisplayer = config.adsDisplayer

        miniAppDownloader = MiniAppDownloader(
            apiClient: miniAppClient,
            manifestDownloader: manifestDownloader,
            status: miniAppStatus
        )

        self.appId = appId
        self.version = version
        self.queryParams = queryParams
        self.messageInterface = config.messageInterface
        self.navigationDelegate = config.navigationDelegate

        super.init()
    }

    deinit {
        MiniAppLogger.d("deallocate MiniAppHandler")
        canGoBackObservation?.invalidate()
        canGoForwardObservation?.invalidate()
        MiniAppAnalytics.sendAnalytics(
            event: .close,
            miniAppId: appId,
            miniAppVersion: version,
            projectId: projectId,
            analyticsConfig: analyticsConfig
        )
        MiniApp.MAOrientationLock = []
        UIViewController.attemptRotationToDeviceOrientation()
        webView?.configuration.userContentController.removeMessageHandler()
        NotificationCenter.default.removeObserver(self)
        secureStorage.unloadStorage()
    }

    required init?(coder: NSCoder) { return nil }

    func load() async throws -> MiniAppWebView? {
        // download
        return nil
    }

    func load(completion: @escaping ((Result<MiniAppWebView, MASDKError>) -> Void)) {
        getMiniAppInfo(miniAppId: appId) { [weak self] result in
            guard let self = self else {
                completion(.failure(.unknownError(domain: "", code: 0, description: "miniapp download failed")))
                return
            }
            switch result {
            case .success(let info):
                self.downloadMiniApp(appInfo: info, queryParams: self.queryParams) { result in
                    switch result {
                    case let .success(state):
                        guard state else {
                            completion(.failure(.unknownError(domain: "", code: 0, description: "miniapp download failed")))
                            return
                        }
                        MiniAppLogger.d("MiniApp loaded with state: \(state)")
                        DispatchQueue.main.async {
                            guard let webView = self.loadWebView(
                                    miniAppId: self.appId,
                                    versionId: info.version.versionId,
                                    queryParams: self.queryParams
                                )
                            else {
                                completion(.failure(.unknownError(domain: "", code: 0, description: "internal error")))
                                return
                            }
                            completion(.success(webView))
                        }
                    case let .failure(error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func loadFromCache(completion: @escaping ((Result<MiniAppWebView, MASDKError>) -> Void)) {
        if appId.isEmpty {
            return completion(.failure(.invalidAppId))
        }
        guard
            !miniAppClient.environment.isPreviewMode
        else {
            return completion(.failure(.unknownError(domain: "", code: 0, description: "MiniApp is not in preview mode")))
        }
        guard
            let cachedVersion = miniAppDownloader.getCachedMiniAppVersion(appId: appId, versionId: version ?? "")
        else {
            return completion(.failure(.miniAppNotFound))
        }
        if miniAppDownloader.isCacheSecure(appId: appId, versionId: cachedVersion) {
            /// Retrieving Cached Manifest Data to get the display name
            //let miniAppInfo = self.miniAppStatus.getMiniAppInfo(appId: appId)
            let cachedMetaData = miniAppManifestStorage.getManifestInfo(forMiniApp: appId)
            verifyRequiredPermissions(
                appId: appId,
                miniAppManifest: cachedMetaData,
                completionHandler: { (result) in
                switch result {
                case .success(let permissionsAgreed):
                    if permissionsAgreed {
                        DispatchQueue.main.async {
                            guard let webView = self.loadWebView(
                                    miniAppId: self.appId,
                                    versionId: cachedVersion,
                                    queryParams: self.queryParams
                                )
                            else {
                                completion(.failure(.unknownError(domain: "", code: 0, description: "internal error")))
                                return
                            }
                            completion(.success(webView))
                        }
                    } else {
                        completion(.failure(.metaDataFailure))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        } else {
            completion(.failure(.miniAppCorrupted))
        }
    }

    func loadWebView(
        miniAppId: String,
        versionId: String,
        queryParams: String? = nil,
        navigationView: (UIView & MiniAppNavigationDelegate)? = nil
    ) -> MiniAppWebView? {
        guard let messageInterface = messageInterface else {
            return nil
        }

        let webView = MiniAppWebView(
            miniAppId: miniAppId,
            versionId: versionId,
            queryParams: queryParams
        )
        self.webView = webView

        webView.navigationDelegate = self

        if navBarVisibility != .never {
            if let nav = navigationView {
                navBar = nav
                isNavBarCustom = true
            } else {
                navBar = MiniAppNavigationBar(frame: .zero)
            }
        }
        navBar?.miniAppNavigation(delegate: self)
        webView.configuration.userContentController.addMiniAppScriptMessageHandler(
            delegate: self,
            hostAppMessageDelegate: messageInterface,
            adsDisplayer: adsDisplayer,
            secureStorageDelegate: self,
            miniAppId: miniAppId,
            miniAppTitle: miniAppId,
            miniAppManageDelegate: self
        )
        webView.configuration.userContentController.addBridgingJavaScript()

//        if !isNavBarCustom {
//            webViewBottomConstraintWithNavBar = navBar?.layoutAttachTop(to: webView)
//            webViewBottomConstraintStandalone?.isActive = false
//        }
        MiniAppAnalytics.sendAnalytics(
            event: .open,
            miniAppId: miniAppId,
            miniAppVersion: version,
            projectId: projectId,
            analyticsConfig: analyticsConfig
        )
        initExternalWebViewClosures()
        observeWebView()

        if shouldAutoLoadSecureStorage {
            secureStorage.loadStorage { success in
                if success {
                    MiniAppSecureStorage.sendLoadStorageReady()
                } else {
                    MiniAppSecureStorage.sendLoadStorageError()
                }
            }
        }
        return webView
    }
}

// MARK: - Info
extension MiniAppViewHandler {
    func getMiniAppInfo(
        miniAppId: String,
        miniAppVersion: String? = nil,
        completionHandler: @escaping (Result<MiniAppInfo, MASDKError>) -> Void
    ) {
        return miniAppInfoFetcher.getInfo(
            miniAppId: miniAppId,
            miniAppVersion: miniAppVersion,
            apiClient: self.miniAppClient,
            completionHandler: completionHandler
        )
    }
}

// MARK: - Download
extension MiniAppViewHandler {
    /// Download Mini app for a given Mini app info object
    /// - Parameters:
    ///   - appInfo: Miniapp Info object
    ///   - queryParams: Optional Query parameters that the host app would like to share while creating a mini app
    ///   - completionHandler: Completion Handler that needed to pass back the MiniAppDisplayProtocol
    func downloadMiniApp(
        appInfo: MiniAppInfo,
        queryParams: String? = nil,
        completionHandler: @escaping (Result<Bool, MASDKError>) -> Void
    ) {
        return miniAppDownloader.verifyAndDownload(
            appId: appInfo.id,
            versionId: appInfo.version.versionId
        ) { (result) in
            switch result {
            case .success:
                self.getMiniAppView(
                    appInfo: appInfo,
                    queryParams: queryParams,
                    completionHandler: completionHandler
                )
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
}

// MARK: - Get
extension MiniAppViewHandler {
    func getMiniAppView(
        appInfo: MiniAppInfo,
        queryParams: String? = nil,
        completionHandler: @escaping (Result<Bool, MASDKError>) -> Void
    ) {
        self.miniAppStatus.setDownloadStatus(true, appId: appInfo.id, versionId: appInfo.version.versionId)
        self.miniAppStatus.setCachedVersion(appInfo.version.versionId, for: appInfo.id)
        verifyUserHasAgreedToManifest(
            miniAppId: appInfo.id,
            versionId: appInfo.version.versionId,
            completionHandler: completionHandler
        )
    }

    /// This method will not compare the Manifest but it wil check if all required permissions are allowed by the user
    func verifyUserHasAgreedToManifest(
        miniAppId: String,
        versionId: String,
        completionHandler: @escaping (Result<Bool, MASDKError>) -> Void
    ) {
        isRequiredPermissionsAllowed(
            appId: miniAppId,
            versionId: versionId
        ) { (result) in
            switch result {
            case .success:
                completionHandler(.success(true))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }

    /// Method to check if all the required permissions mentioned in the manifest.json is agreed by the user.
    /// - Parameters:
    ///   - appId: MiniApp ID
    ///   - versionId: Specific VersionID of a MiniApp
    ///   - completionHandler: Handler that returns whether user agreed to required permissions or not.
    func isRequiredPermissionsAllowed(
        appId: String,
        versionId: String,
        completionHandler: @escaping (Result<Bool, MASDKError>) -> Void
    ) {
        let cachedMetaData = miniAppManifestStorage.getManifestInfo(forMiniApp: appId)
        if cachedMetaData?.versionId != versionId || miniAppClient.environment.isPreviewMode {
            retrieveMiniAppMetaData(appId: appId, version: versionId) { (result) in
                switch result {
                case .success(let manifest):
                    self.miniAppManifestStorage.saveManifestInfo(
                        forMiniApp: appId,
                        manifest: manifest
                    )
                    self.verifyRequiredPermissions(
                        appId: appId,
                        miniAppManifest: manifest,
                        completionHandler: completionHandler
                    )
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
        } else {
            self.verifyRequiredPermissions(
                appId: appId,
                miniAppManifest: cachedMetaData,
                completionHandler: completionHandler
            )
        }
    }

    func retrieveMiniAppMetaData(
        appId: String,
        version: String,
        languageCode: String? = nil,
        completionHandler: @escaping (Result<MiniAppManifest, MASDKError>) -> Void
    ) {
        if appId.isEmpty {
            return completionHandler(.failure(.invalidAppId))
        }
        if version.isEmpty {
            return completionHandler(.failure(.invalidVersionId))
        }
        metaDataDownloader.getMiniAppMetaInfo(
            miniAppId: appId,
            miniAppVersion: version,
            apiClient: self.miniAppClient,
            languageCode: (languageCode ?? NSLocale.current.languageCode) ?? ""
        ) { (result) in
            switch result {
            case .success(let metaData):
                completionHandler(.success(metaData))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }

    /// Method that compares the required permissions from the manifest and the stored custom permissions.
    /// - Parameters:
    ///   - appId: MiniApp ID
    ///   - requiredPermissions: List of required Custom permissions that is defined by the Mini App
    ///   - completionHandler: Handler that returns whether user agreed to required permissions or not.
    func verifyRequiredPermissions(
        appId: String,
        miniAppManifest: MiniAppManifest?,
        completionHandler: @escaping (Result<Bool, MASDKError>) -> Void
    ) {
        guard let manifestData = miniAppManifest, let requiredPermissions = manifestData.requiredPermissions else {
            miniAppPermissionStorage.removeKey(for: appId)
            return completionHandler(.success(true))
        }
        let storedCustomPermissions = self.miniAppPermissionStorage.getCustomPermissions(forMiniApp: appId)
        let filterStoredRequiredPermissions = storedCustomPermissions.filter {
            requiredPermissions.contains($0)
        }
        /// Required permissions stored in the Cache and Required permissions(Retrieved recently) should be same.
        /// If they are not equal, then either user haven't agreed to any required permissions OR manifest has changed.
        if
            filterStoredRequiredPermissions.count == requiredPermissions.count &&
            filterStoredRequiredPermissions.allSatisfy({ $0.isPermissionGranted.boolValue == true }) {
            miniAppPermissionStorage.removeKey(for: appId)
            miniAppPermissionStorage
                .storeCustomPermissions(permissions:
                    filterCustomPermissions(
                        forMiniApp: appId,
                        cachedPermissions: storedCustomPermissions
                    ),
                    forMiniApp: appId
                )
            completionHandler(.success(true))
        } else {
            completionHandler(.failure(.metaDataFailure))
        }
    }

    func filterCustomPermissions(forMiniApp id: String, cachedPermissions: [MASDKCustomPermissionModel]) -> [MASDKCustomPermissionModel] {
        guard let manifestData = getCachedManifestData(appId: id) else {
            return cachedPermissions
        }
        let manifestCustomPermissions = (manifestData.requiredPermissions ?? []) + (manifestData.optionalPermissions ?? [])
        let filtered = cachedPermissions.filter {
            manifestCustomPermissions.contains($0)
        }
        return filtered
    }

    /// Method that returns the Cached MiniAppManifest from the Keychain
    /// - Parameter appId: MiniApp ID
    /// - Returns: MiniAppManifest object
    func getCachedManifestData(appId: String) -> MiniAppManifest? {
        miniAppManifestStorage.getManifestInfo(forMiniApp: appId)
    }
}

// MARK: - RealMiniApp
extension MiniAppViewHandler: MiniAppNavigationBarDelegate {
    public func miniAppShouldClose() -> CloseAlertInfo? {
        return self.closeAlertInfo
    }

    public func miniAppNavigationBar(didTriggerAction action: MiniAppNavigationAction) -> Bool {
        guard let webView = webView else { return false }
        let canDo: Bool
        switch action {
        case .back:
            canDo = webView.canGoBack
            webView.goBack()
        case .forward:
            canDo = webView.canGoForward
            webView.goForward()
        }
        return canDo
    }
}

// MARK: WKNavigationDelegate
extension MiniAppViewHandler: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let requestUrl = navigationAction.request.url {
            MiniAppLogger.d("navigation type for \(navigationAction.request.url?.absoluteString ?? "---"): \(navigationAction.navigationType.rawValue)")
            validateScheme(requestURL: requestUrl, navigationAction: navigationAction, decisionHandler: decisionHandler)
        } else {
            decisionHandler(.cancel)
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        refreshNavBar()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        MiniAppLogger.e("Couldn't load Miniapp URL", error)
        initialLoadCallback?(false)
        initialLoadCallback = nil
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        initialLoadCallback?(true)
        initialLoadCallback = nil
    }

    func validateScheme(requestURL: URL, navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let scheme = requestURL.scheme {
            let schemeType = MiniAppSupportedSchemes(rawValue: scheme)
            switch schemeType {
            case .about: // mainly implemented to manage built-in alert dialogs
                return decisionHandler(.allow)
            case .tel, .mailto:
                UIApplication.shared.open(requestURL, options: [:], completionHandler: nil)
            default:
                if requestURL.isMiniAppURL(customMiniAppURL: miniAppURL) {
                    return decisionHandler(.allow)
                } else if requestURL.isBase64 {
                    if
                        MiniApp.shared()
                            .getCustomPermissions(forMiniApp: appId)
                            .filter({ $0.permissionName == .fileDownload && $0.isPermissionGranted == .allowed })
                            .first != nil {
                        if let onResponse = onExternalWebviewResponse, let onClose = onExternalWebviewClose {
                            navigationDelegate?.miniAppNavigation(shouldOpen: requestURL, with: onResponse, onClose: onClose)
                        }
                    }
                    return decisionHandler(.cancel)
                } else {
                    // Allow navigation for requests loading external web content resources. E.G: iFrames
                    guard navigationAction.targetFrame?.isMainFrame != false else {
                        return decisionHandler(.allow)
                    }

                    if let onResponse = onExternalWebviewResponse, let onClose = onExternalWebviewClose {
                        if let miniAppURL = miniAppURL {
                            NotificationCenter.default.sendCustomEvent(MiniAppEvent.Event(type: .pause, comment: "MiniApp opened external webview"))
                            navigationDelegate?.miniAppNavigation(shouldOpen: requestURL, with: onResponse, onClose: onClose, customMiniAppURL: miniAppURL)
                        } else {
                            NotificationCenter.default.sendCustomEvent(MiniAppEvent.Event(type: .pause, comment: "MiniApp opened external webview"))
                            navigationDelegate?.miniAppNavigation(shouldOpen: requestURL, with: onResponse, onClose: onClose)
                        }
                    }
                }
            }
        }
        decisionHandler(.cancel)
    }

    func refreshNavBar() {
//        var actionsAvailable = [MiniAppNavigationAction]()
//        if webView.canGoBack || navBarVisibility == .always {
//            actionsAvailable.append(.back)
//        }
//        if webView.canGoForward || navBarVisibility == .always {
//            actionsAvailable.append(.forward)
//        }
//        navigationDelegate?.miniAppNavigation(canUse: actionsAvailable)
//        if actionsAvailable.count == 0 && navBarVisibility != .never {
//            webViewBottomConstraintStandalone?.isActive = navBarVisibility == .auto
//            webViewBottomConstraintWithNavBar?.isActive = navBarVisibility == .always
//            navBar?.removeFromSuperview()
//        } else {
//            if let nav = navBar {
//                let navDelegate = navigationDelegate as? UIView
//                if navDelegate == nil || navDelegate != nav {
//                    nav.miniAppNavigation(canUse: actionsAvailable)
//                }
//
//                if navBarVisibility != .never {
//                    addSubview(nav)
//                    nav.translatesAutoresizingMaskIntoConstraints = false
//                    webViewBottomConstraintStandalone?.isActive = isNavBarCustom
//                    webViewBottomConstraintWithNavBar?.isActive = !isNavBarCustom
//                    nav.layoutAttachBottom()
//                    nav.layoutAttachLeading()
//                    nav.layoutAttachTrailing()
//                }
//            } else {
//                webViewBottomConstraintWithNavBar?.isActive = false
//                webViewBottomConstraintStandalone?.isActive = true
//            }
//        }
    }
}

extension MiniAppViewHandler {
    fileprivate func initExternalWebViewClosures() {
        onExternalWebviewResponse = { [weak self] (url) in
            self?.webView?.load(URLRequest(url: url))
        }
        onExternalWebviewClose = { [weak self] (url) in
            self?.didReceiveEvent(.externalWebViewClosed, message: url.absoluteString)
            NotificationCenter.default.sendCustomEvent(MiniAppEvent.Event(type: .resume, comment: "MiniApp close external webview"))
        }
    }

    func observeWebView() {
        canGoBackObservation = webView?.observe(\.canGoBack, options: .initial) { [weak self] (webView, _) in
            self?.navigationDelegate?.miniAppNavigationCanGo(back: webView.canGoBack, forward: webView.canGoForward)
        }
        canGoForwardObservation = webView?.observe(\.canGoForward) { [weak self] (webView, _) in
            self?.navigationDelegate?.miniAppNavigationCanGo(back: webView.canGoBack, forward: webView.canGoForward)
        }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sendCustomEvent(notification:)),
                                               name: MiniAppEvent.notificationName,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sendCustomEvent(notification:)),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sendCustomEvent(notification:)),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        // keyboard events
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sendKeyboardEvent(notification:)),
                                               name: MiniAppKeyboardEvent.notificationName,
                                               object: nil)
    }

    @objc
    func sendCustomEvent(notification: NSNotification) {
        switch notification.name {
        case UIApplication.willResignActiveNotification:
            didReceiveEvent(.pause, message: "Host app will resign active")
        case UIApplication.didBecomeActiveNotification:
            didReceiveEvent(.resume, message: "Host app did become active")
        default:
            if let event = notification.object as? MiniAppEvent.Event {
                didReceiveEvent(event.type, message: event.comment)
            } else {
                MiniAppLogger.w("MiniAppEvent not present in notification")
            }
        }
    }

    @objc
    func sendKeyboardEvent(notification: NSNotification) {
        if notification.name == MiniAppKeyboardEvent.notificationName {
            if let event = notification.object as? MiniAppKeyboardEvent.Event {
                didReceiveKeyboardEvent(event.type, message: event.comment, navigationBarHeight: event.navigationBarHeight, screenHeight: event.screenHeight, keyboardHeight: event.keyboardHeight)
            } else {
                MiniAppLogger.w("MiniAppEvent not present in notification")
            }
        }
    }
}

// MARK: - MiniAppDisplayDelegate
extension MiniAppViewHandler: MiniAppManageDelegate {
    func setMiniAppCloseAlertInfo(alertInfo: CloseAlertInfo?) {
        self.closeAlertInfo = alertInfo
    }
}

// MARK: - MiniAppCallbackDelegate
extension MiniAppViewHandler: MiniAppCallbackDelegate {
    func didReceiveScriptMessageResponse(messageId: String, response: String) {
        let messageBody = Constants.JavaScript.successCallback + "('\(messageId)'," + "'\(response)')"
        messageBodies.append(messageBody)
        MiniAppLogger.d(messageBody, "♨️️")
        webView?.evaluateJavaScript(messageBody)
    }

    func didReceiveScriptMessageError(messageId: String, errorMessage: String) {
        let messageBody = Constants.JavaScript.errorCallback + "('\(messageId)'," + "'\(errorMessage)')"
        messageBodies.append(messageBody)
        MiniAppLogger.d(messageBody, "♨️️")
        webView?.evaluateJavaScript(messageBody)
    }

    func didOrientationChanged(orientation: UIInterfaceOrientationMask) {
        self.supportedMiniAppOrientation = orientation
    }

    func didReceiveEvent(_ event: MiniAppEvent, message: String) {
        let messageBody = Constants.JavaScript.eventCallback + "('\(event.rawValue)'," + "'\(message)')"
        messageBodies.append(messageBody)
        MiniAppLogger.d(messageBody, "♨️️")
        webView?.evaluateJavaScript(messageBody)
    }

    func didReceiveKeyboardEvent(_ event: MiniAppKeyboardEvent, message: String, navigationBarHeight: CGFloat? = nil, screenHeight: CGFloat? = nil, keyboardHeight: CGFloat? = nil) {
        var messageBody = Constants.JavaScript.keyboardEventCallback + "('\(event.rawValue)'," + "'\(message)'"
        if let navigationBarHeight = navigationBarHeight, let screenHeight = screenHeight, let keyboardHeight = keyboardHeight {
            messageBody += ",'\(navigationBarHeight)','\(screenHeight)','\(keyboardHeight)')"
        } else {
            messageBody += ")"
        }
        messageBodies.append(messageBody)
        MiniAppLogger.d(messageBody, "♨️️")
        webView?.evaluateJavaScript(messageBody)
    }
}

// MARK: - MiniAppSecureStorageDelegate
extension MiniAppViewHandler: MiniAppSecureStorageDelegate {
    func get(key: String) throws -> String? {
        return try secureStorage.get(key: key)
    }

    func set(dict: [String: String], completion: ((Result<Bool, MiniAppSecureStorageError>) -> Void)?) {
        return secureStorage.set(dict: dict, completion: completion)
    }

    func remove(keys: [String], completion: ((Result<Bool, MiniAppSecureStorageError>) -> Void)?) {
        return secureStorage.remove(keys: keys, completion: completion)
    }

    func size() -> MiniAppSecureStorageSize {
        return secureStorage.size()
    }

    func clearSecureStorage() throws {
        try secureStorage.clearSecureStorage()
    }
}
