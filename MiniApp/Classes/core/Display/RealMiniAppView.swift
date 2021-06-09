import WebKit

internal class RealMiniAppView: UIView {

    internal var webView: WKWebView
    internal var miniAppTitle: String
    internal var queryParams: String?
    internal var miniAppURL: URL?
    internal var miniAppId: String?
    internal var projectId: String?
    internal var miniAppVersion: String?
    internal var navBar: (UIView & MiniAppNavigationDelegate)?
    internal var webViewBottomConstraintStandalone: NSLayoutConstraint?
    internal var webViewBottomConstraintWithNavBar: NSLayoutConstraint?
    internal var navBarVisibility: MiniAppNavigationVisibility
    internal var isNavBarCustom = false
    internal var supportedMiniAppOrientation: UIInterfaceOrientationMask
    internal var initialLoadCallback: ((Bool) -> Void)?
    internal var analyticsConfig: [MAAnalyticsConfig]?

    internal weak var hostAppMessageDelegate: MiniAppMessageDelegate?
    internal weak var navigationDelegate: MiniAppNavigationDelegate?
    internal weak var currentDialogController: UIAlertController?

    init(
        miniAppId: String,
        versionId: String,
        projectId: String,
        miniAppTitle: String,
        queryParams: String? = nil,
        hostAppMessageDelegate: MiniAppMessageDelegate,
        adsDisplayer: MiniAppAdDisplayer? = nil,
        displayNavBar: MiniAppNavigationVisibility = .never,
        navigationDelegate: MiniAppNavigationDelegate? = nil,
        navigationView: (UIView & MiniAppNavigationDelegate)? = nil,
        analyticsConfig: [MAAnalyticsConfig]? = []) {

        self.miniAppTitle = miniAppTitle
        webView = MiniAppWebView(miniAppId: miniAppId, versionId: versionId, queryParams: queryParams)
        self.hostAppMessageDelegate = hostAppMessageDelegate
        navBarVisibility = displayNavBar
        supportedMiniAppOrientation = []
        self.miniAppVersion = versionId
        self.projectId = projectId
        self.analyticsConfig = analyticsConfig
        super.init(frame: .zero)
        commonInit(miniAppId: miniAppId,
                   hostAppMessageDelegate: hostAppMessageDelegate,
                   adsDisplayer: adsDisplayer,
                   navigationDelegate: navigationDelegate,
                   navigationView: navigationView)
    }

    init(
        miniAppURL: URL,
        miniAppTitle: String,
        queryParams: String? = nil,
        hostAppMessageDelegate: MiniAppMessageDelegate,
        adsDisplayer: MiniAppAdDisplayer? = nil,
        initialLoadCallback: ((Bool) -> Void)? = nil,
        displayNavBar: MiniAppNavigationVisibility = .never,
        navigationDelegate: MiniAppNavigationDelegate? = nil,
        navigationView: (UIView & MiniAppNavigationDelegate)? = nil,
        analyticsConfig: [MAAnalyticsConfig]? = []) {

        self.miniAppTitle = miniAppTitle
        self.miniAppURL = miniAppURL
        self.initialLoadCallback = initialLoadCallback
        webView = MiniAppWebView(miniAppURL: miniAppURL)
        self.hostAppMessageDelegate = hostAppMessageDelegate
        navBarVisibility = displayNavBar
        supportedMiniAppOrientation = []
        self.analyticsConfig = analyticsConfig

        super.init(frame: .zero)
        commonInit(miniAppId: "custom\(Int32.random(in: 0...Int32.max))", // some id is needed to handle permissions
                   hostAppMessageDelegate: hostAppMessageDelegate,
                   adsDisplayer: adsDisplayer,
                   navigationDelegate: navigationDelegate,
                   navigationView: navigationView)
    }

    required init?(coder: NSCoder) {
        nil
    }

    private func commonInit(
        miniAppId: String,
        hostAppMessageDelegate: MiniAppMessageDelegate,
        adsDisplayer: MiniAppAdDisplayer? = nil,
        navigationDelegate: MiniAppNavigationDelegate? = nil,
        navigationView: (UIView & MiniAppNavigationDelegate)? = nil) {
        self.miniAppId = miniAppId

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
        webView.configuration.userContentController.addMiniAppScriptMessageHandler(delegate: self,
                                                                                   hostAppMessageDelegate: hostAppMessageDelegate,
                                                                                   adsDisplayer: adsDisplayer,
                                                                                   miniAppId: miniAppId,
                                                                                   miniAppTitle: self.miniAppTitle)
        webView.configuration.userContentController.addBridgingJavaScript()
        webView.uiDelegate = self
        self.navigationDelegate = navigationDelegate
        addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.layoutAttachTop()
        webViewBottomConstraintStandalone = webView.layoutAttachBottom()
        webView.layoutAttachLeading()
        webView.layoutAttachTrailing()
        if !isNavBarCustom {
            webViewBottomConstraintWithNavBar = navBar?.layoutAttachTop(to: webView)
            webViewBottomConstraintStandalone?.isActive = false
        }
        MiniAppAnalytics.sendAnalytics(event: .open, miniAppId: miniAppId, miniAppVersion: miniAppVersion, projectId: projectId, analyticsConfig: analyticsConfig)
    }

    func refreshNavBar() {
        var actionsAvailable = [MiniAppNavigationAction]()
        if webView.canGoBack || navBarVisibility == .always {
            actionsAvailable.append(.back)
        }
        if webView.canGoForward || navBarVisibility == .always {
            actionsAvailable.append(.forward)
        }
        navigationDelegate?.miniAppNavigation(canUse: actionsAvailable)
        if actionsAvailable.count == 0 && navBarVisibility != .never {
            webViewBottomConstraintStandalone?.isActive = navBarVisibility == .auto
            webViewBottomConstraintWithNavBar?.isActive = navBarVisibility == .always
            navBar?.removeFromSuperview()
        } else {
            if let nav = navBar {
                let navDelegate = navigationDelegate as? UIView
                if navDelegate == nil || navDelegate != nav {
                    nav.miniAppNavigation(canUse: actionsAvailable)
                }

                if navBarVisibility != .never {
                    addSubview(nav)
                    nav.translatesAutoresizingMaskIntoConstraints = false
                    webViewBottomConstraintStandalone?.isActive = false || isNavBarCustom
                    webViewBottomConstraintWithNavBar?.isActive = true && !isNavBarCustom
                    nav.layoutAttachBottom()
                    nav.layoutAttachLeading()
                    nav.layoutAttachTrailing()
                }
            } else {
                webViewBottomConstraintWithNavBar?.isActive = false
                webViewBottomConstraintStandalone?.isActive = true
            }
        }
    }

    deinit {
        MiniAppAnalytics.sendAnalytics(event: .close, miniAppId: miniAppId, miniAppVersion: miniAppVersion, projectId: projectId, analyticsConfig: analyticsConfig)
        MiniApp.MAOrientationLock = []
        UIViewController.attemptRotationToDeviceOrientation()
        webView.configuration.userContentController.removeMessageHandler()
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
                } else {
                    // Allow navigation for requests loading external web content resources. E.G: iFrames
                    guard navigationAction.targetFrame?.isMainFrame != false else {
                        return decisionHandler(.allow)
                    }
                    if let miniAppURL = miniAppURL {
                        self.navigationDelegate?.miniAppNavigation(shouldOpen: requestURL, with: { (url) in
                            self.webView.load(URLRequest(url: url))
                        }, customMiniAppURL: miniAppURL)
                    } else {
                        self.navigationDelegate?.miniAppNavigation(shouldOpen: requestURL, with: { (url) in
                            self.webView.load(URLRequest(url: url))
                        })
                    }
                }
            }
        }
        decisionHandler(.cancel)
    }

    internal func presentAlert(alertController: UIAlertController) {
        UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
    }
}

extension RealMiniAppView: MiniAppDisplayDelegate {
    public func getMiniAppView() -> UIView {
        self
    }
}

extension RealMiniAppView: MiniAppCallbackDelegate {
    func didReceiveScriptMessageResponse(messageId: String, response: String) {
        let messageBody = Constants.javascriptSuccessCallback + "('\(messageId)'," + "'\(response)')"
        MiniAppLogger.d(messageBody, "♨️️")
        webView.evaluateJavaScript(messageBody)
    }

    func didReceiveScriptMessageError(messageId: String, errorMessage: String) {
        let messageBody = Constants.javascriptErrorCallback + "('\(messageId)'," + "'\(errorMessage)')"
        MiniAppLogger.d(messageBody, "♨️️")
        webView.evaluateJavaScript(messageBody)
    }

    func didOrientationChanged(orientation: UIInterfaceOrientationMask) {
        self.supportedMiniAppOrientation = orientation
    }
}

extension RealMiniAppView: MiniAppNavigationBarDelegate {
    func miniAppNavigationBar(didTriggerAction action: MiniAppNavigationAction) -> Bool {
        let canDo: Bool
        switch action {
        case .back:
            canDo = self.webView.canGoBack
            self.webView.goBack()
        case .forward:
            canDo = self.webView.canGoForward
            self.webView.goForward()
        }
        return canDo
    }
}

extension RealMiniAppView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let requestUrl = navigationAction.request.url {
            MiniAppLogger.d("navigation type for \(navigationAction.request.url?.absoluteString ?? "---"): \(navigationAction.navigationType.rawValue)")
            validateScheme(requestURL: requestUrl, navigationAction: navigationAction, decisionHandler: decisionHandler)
        } else {
            decisionHandler(.cancel)
        }
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
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
}
