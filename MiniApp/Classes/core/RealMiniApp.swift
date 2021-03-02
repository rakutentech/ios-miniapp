internal class RealMiniApp {
    var miniAppInfoFetcher: MiniAppInfoFetcher
    var miniAppClient: MiniAppClient
    var miniAppDownloader: MiniAppDownloader
    var manifestDownloader: ManifestDownloader
    var displayer: Displayer
    var miniAppStatus: MiniAppStatus
    var miniAppPermissionStorage: MiniAppPermissionsStorage
    var miniAppScopeStorage: MiniAppScopeStorage
    let offlineErrorCodeList: [Int] = [NSURLErrorNotConnectedToInternet, NSURLErrorTimedOut]

    convenience init() {
        self.init(with: nil)
    }

    init(with settings: MiniAppSdkConfig?, and navigationSettings: MiniAppNavigationConfig? = nil) {
        miniAppInfoFetcher = MiniAppInfoFetcher()
        miniAppClient = MiniAppClient(baseUrl: settings?.baseUrl,
                                           rasProjectId: settings?.rasProjectId,
                                           subscriptionKey: settings?.subscriptionKey,
                                           hostAppVersion: settings?.hostAppVersion,
                                           isPreviewMode: settings?.isPreviewMode)
        manifestDownloader = ManifestDownloader()
        miniAppStatus = MiniAppStatus()
        miniAppPermissionStorage = MiniAppPermissionsStorage()
        miniAppScopeStorage = MiniAppScopeStorage()

        miniAppDownloader = MiniAppDownloader(apiClient: self.miniAppClient, manifestDownloader: self.manifestDownloader, status: self.miniAppStatus)
        displayer = Displayer(navigationSettings)
    }

    func update(with settings: MiniAppSdkConfig?, navigationSettings: MiniAppNavigationConfig? = nil) {
        self.miniAppClient.updateEnvironment(with: settings)
        self.displayer.navConfig = navigationSettings
    }

    func listMiniApp(completionHandler: @escaping (Result<[MiniAppInfo], MASDKError>) -> Void) {
        return miniAppInfoFetcher.fetchList(apiClient: self.miniAppClient, completionHandler: self.createCompletionHandler(completionHandler: completionHandler))
    }

    func getMiniApp(miniAppId: String, miniAppVersion: String? = nil, completionHandler: @escaping (Result<MiniAppInfo, MASDKError>) -> Void) {
        return miniAppInfoFetcher.getInfo(miniAppId: miniAppId, miniAppVersion: miniAppVersion, apiClient: self.miniAppClient,
                                                  completionHandler: self.createCompletionHandler(completionHandler: completionHandler))
    }

    /// For a given Miniapp info object, this method will check whether the version id is the latest one with the platform.
    /// If the versions doesn't match it will start downloading the latest version, if the versions match the same object
    /// will be passed on to Downloader class (which will check whether the mini app is downloaded already if not, it will download)
    /// - Parameters:
    ///   - appInfo: Miniapp Info object
    ///   - queryParams: Optional Query parameters that the host app would like to share while creating a mini app
    ///   - completionHandler: Completion Handler that needed to pass back the MiniAppDisplayProtocol
    ///   - messageInterface: Miniapp communication protocol object.
    ///   - adsDisplayer: a delegate that will handle Miniapp ads requests
    func createMiniApp(appInfo: MiniAppInfo, scopes: [MASDKAccessTokenPermission]?, queryParams: String? = nil, completionHandler: @escaping (Result<MiniAppDisplayDelegate, Error>) -> Void, messageInterface: MiniAppMessageDelegate? = nil, adsDisplayer: MiniAppAdDisplayer? = nil) {
        getMiniApp(miniAppId: appInfo.id, miniAppVersion: appInfo.version.versionId) { (result) in
            switch result {
            case .success(let responseData):
                if appInfo.version.versionId != responseData.version.versionId {
                    self.downloadMiniApp(
                            appInfo: responseData,
                            scopes: scopes,
                            queryParams: queryParams,
                            completionHandler: completionHandler,
                            messageInterface: messageInterface,
                            adsDisplayer: adsDisplayer)
                    return
                }
                self.downloadMiniApp(
                        appInfo: appInfo,
                        scopes: scopes,
                        queryParams: queryParams,
                        completionHandler: completionHandler,
                        messageInterface: messageInterface)
            case .failure(let error):
                self.handleMiniAppDownloadError(
                        appId: appInfo.id,
                        scopes: scopes,
                        error: error,
                        queryParams: queryParams,
                        completionHandler: completionHandler,
                        messageInterface: messageInterface,
                        adsDisplayer: adsDisplayer)
            } }
    }

    func createMiniApp(appId: String, scopes: [MASDKAccessTokenPermission]?, version: String? = nil, queryParams: String? = nil, completionHandler: @escaping (Result<MiniAppDisplayDelegate, MASDKError>) -> Void, messageInterface: MiniAppMessageDelegate? = nil, adsDisplayer: MiniAppAdDisplayer? = nil) {
        getMiniApp(miniAppId: appId, miniAppVersion: version) { (result) in
            switch result {
            case .success(let responseData):
                self.miniAppStatus.saveMiniAppInfo(appInfo: responseData, key: responseData.id)
                self.downloadMiniApp(appInfo: responseData,
                                     scopes: scopes,
                                     queryParams: queryParams,
                                     completionHandler: self.createCompletionHandler(completionHandler: completionHandler),
                                     messageInterface: messageInterface,
                                     adsDisplayer: adsDisplayer)
            case .failure(let error):
                self.handleMiniAppDownloadError(appId: appId,
                                 scopes: scopes,
                                 error: error,
                                 queryParams: queryParams,
                                 completionHandler: self.createCompletionHandler(completionHandler: completionHandler),
                                 messageInterface: messageInterface,
                                 adsDisplayer: adsDisplayer)
            } }
    }

    func createMiniApp(url: URL, miniAppScopes: [MASDKAccessTokenPermission]? = nil, queryParams: String? = nil, errorHandler: @escaping (Error) -> Void, messageInterface: MiniAppMessageDelegate? = nil, adsDisplayer: MiniAppAdDisplayer? = nil) -> MiniAppDisplayDelegate {
        displayer.getMiniAppView(miniAppURL: url,
                                        miniAppTitle: "Mini app",
                                        miniAppScopes: miniAppScopes,
                                        queryParams: queryParams,
                                        hostAppMessageDelegate: messageInterface ?? self,
                                        adsDisplayer: adsDisplayer,
                                        initialLoadCallback: { success in
            if !success {
                errorHandler(NSError.invalidURLError())
            }
        })
    }

    /// Download Mini app for a given Mini app info object
    /// - Parameters:
    ///   - appInfo: Miniapp Info object
    ///   - queryParams: Optional Query parameters that the host app would like to share while creating a mini app
    ///   - completionHandler: Completion Handler that needed to pass back the MiniAppDisplayProtocol
    ///   - messageInterface: Miniapp communication protocol object.
    ///   - adsDisplayer: a MiniAppAdDisplayer that will handle Miniapp ads requests
    func downloadMiniApp(appInfo: MiniAppInfo,
                         scopes: [MASDKAccessTokenPermission]?,
                         queryParams: String? = nil,
                         completionHandler: @escaping (Result<MiniAppDisplayDelegate, Error>) -> Void,
                         messageInterface: MiniAppMessageDelegate? = nil,
                         adsDisplayer: MiniAppAdDisplayer? = nil) {
        return miniAppDownloader.verifyAndDownload(appId: appInfo.id, versionId: appInfo.version.versionId) { (result) in
            switch result {
            case .success:
                self.getMiniAppView(
                        appInfo: appInfo,
                        miniAppScopes: scopes,
                        queryParams: queryParams,
                        completionHandler: completionHandler,
                        messageInterface: messageInterface,
                        adsDisplayer: adsDisplayer)
            case .failure(let error):
                self.handleMiniAppDownloadError(
                        appId: appInfo.id,
                        scopes: scopes,
                        error: error,
                        queryParams: queryParams,
                        completionHandler: completionHandler,
                        messageInterface: messageInterface,
                        adsDisplayer: adsDisplayer)
            }
        }
    }

    func getMiniAppView(appInfo: MiniAppInfo, miniAppScopes: [MASDKAccessTokenPermission]?, queryParams: String? = nil, completionHandler: @escaping (Result<MiniAppDisplayDelegate, Error>) -> Void, messageInterface: MiniAppMessageDelegate? = nil, adsDisplayer: MiniAppAdDisplayer? = nil) {
        DispatchQueue.main.async {
            let miniAppDisplayProtocol = self.displayer.getMiniAppView(miniAppId: appInfo.id,
                                                                       versionId: appInfo.version.versionId,
                                                                       projectId: self.miniAppClient.environment.projectId,
                                                                       miniAppTitle: appInfo.displayName ?? "Mini app",
                                                                       miniAppScopes: miniAppScopes,
                                                                       queryParams: queryParams,
                                                                       hostAppMessageDelegate: messageInterface ?? self,
                                                                       adsDisplayer: adsDisplayer)
            self.miniAppStatus.setDownloadStatus(true, appId: appInfo.id, versionId: appInfo.version.versionId)
            self.miniAppStatus.setCachedVersion(appInfo.version.versionId, for: appInfo.id)
            completionHandler(.success(miniAppDisplayProtocol))
        }
    }

    func handleMiniAppDownloadError(appId: String,
                                    scopes: [MASDKAccessTokenPermission]?,
                                    error: Error,
                                    queryParams: String? = nil,
                                    completionHandler: @escaping (Result<MiniAppDisplayDelegate, Error>) -> Void,
                                    messageInterface: MiniAppMessageDelegate? = nil,
                                    adsDisplayer: MiniAppAdDisplayer? = nil) {
        let downloadError = error as NSError
        if self.offlineErrorCodeList.contains(downloadError.code) {
            guard let miniAppInfo = self.miniAppStatus.getMiniAppInfo(appId: appId) else {
                return completionHandler(.failure(error))
            }
            guard let cachedVersion = miniAppDownloader.getCachedMiniAppVersion(appId: miniAppInfo.id, versionId: miniAppInfo.version.versionId) else {
                return completionHandler(.failure(downloadError))
            }
            DispatchQueue.main.async {
                let miniAppDisplayProtocol = self.displayer.getMiniAppView(miniAppId: appId,
                                                                           versionId: cachedVersion,
                                                                           projectId: self.miniAppClient.environment.projectId,
                                                                           miniAppTitle: miniAppInfo.displayName ?? "Mini App",
                                                                           miniAppScopes: scopes,
                                                                           queryParams: queryParams,
                                                                           hostAppMessageDelegate: messageInterface ?? self,
                                                                           adsDisplayer: adsDisplayer)
                completionHandler(.success(miniAppDisplayProtocol))
            }
        } else {
            completionHandler(.failure(error))
        }
    }

    func retrieveCustomPermissions(forMiniApp id: String) -> [MASDKCustomPermissionModel] {
        miniAppPermissionStorage.getCustomPermissions(forMiniApp: id)
    }

    func storeCustomPermissions(forMiniApp id: String, permissionList: [MASDKCustomPermissionModel]) {
        miniAppPermissionStorage.storeCustomPermissions(permissions: permissionList, forMiniApp: id)
    }

    func retrieveScopes(forMiniApp id: String) -> [MASDKAccessTokenPermission] {
        miniAppScopeStorage.getScopes(forMiniApp: id)
    }

    func storeScopes(forMiniApp id: String, scopes: [MASDKAccessTokenPermission]) {
        miniAppScopeStorage.setScopes(scopes: scopes, forMiniApp: id)
    }

    func getDownloadedListWithCustomPermissions() -> MASDKDownloadedListPermissionsPair {
        miniAppStatus.getMiniAppsListWithCustomPermissionsInfo() ?? []
    }

    func createCompletionHandler<T>(completionHandler: @escaping (Result<T, MASDKError>) -> Void) -> (Result<T, Error>) -> Void { { (result) in
            switch result {
            case .success(let responseData):
                completionHandler(.success(responseData))
            case .failure(let error):
                completionHandler(.failure(.fromError(error: error)))
            }
        }
    }

    func retrieveMiniAppMetaData(appId: String,
                                 version: String,
                                 completionHandler: @escaping (Result<MiniAppManifest, MASDKError>) -> Void) {
        if appId.isEmpty {
            return completionHandler(.failure(.invalidAppId))
        }
        if version.isEmpty {
            return completionHandler(.failure(.invalidVersionId))
        }
        miniAppInfoFetcher.getMiniAppMetaInfo(miniAppId: appId,
                                              miniAppVersion: version,
                                              apiClient: self.miniAppClient, completionHandler: self.createCompletionHandler(completionHandler: completionHandler))
    }

    /// Method to remove the unused/deleted items from the Keychain
    func cleanUpKeychain() {
        self.miniAppStatus.removeUnusedCustomPermissions()
    }
}

extension RealMiniApp: MiniAppMessageDelegate {
    func requestCustomPermissions(permissions: [MASDKCustomPermissionModel], completionHandler: @escaping (Result<[MASDKCustomPermissionModel], MASDKCustomPermissionError>) -> Void) {
        completionHandler(.failure(.failedToConformToProtocol))
    }

    func requestDevicePermission(permissionType: MiniAppDevicePermissionType, completionHandler: @escaping (Result<MASDKPermissionResponse, MASDKPermissionError>) -> Void) {
        completionHandler(.failure(.failedToConformToProtocol))
    }

    func getUniqueId() -> String {
        "MiniAppMessageBridge has not been implemented by the host app"
    }

    func shareContent(info: MiniAppShareContent, completionHandler: @escaping (Result<MASDKProtocolResponse, Error>) -> Void) {
        let error: NSError = NSError.init(domain: "MiniAppMessageBridge has not been implemented by the host app", code: 0, userInfo: nil)
        completionHandler(.failure(error as Error))
    }
}
