internal class RealMiniApp {
    var miniAppInfoFetcher: MiniAppInfoFetcher
    var metaDataDownloader: MetaDataDownloader
    var miniAppClient: MiniAppClient
    var miniAppDownloader: MiniAppDownloader
    var manifestDownloader: ManifestDownloader
    var displayer: Displayer
    var miniAppStatus: MiniAppStatus
    var miniAppPermissionStorage: MiniAppPermissionsStorage
    var miniAppManifestStorage: MAManifestStorage
    var miniAppAnalyticsConfig: [MAAnalyticsConfig]

    convenience init() {
        self.init(with: nil)
    }

    init(with settings: MiniAppSdkConfig?, and navigationSettings: MiniAppNavigationConfig? = nil) {
        self.miniAppInfoFetcher = MiniAppInfoFetcher()
        self.metaDataDownloader = MetaDataDownloader()
        self.miniAppClient = MiniAppClient(baseUrl: settings?.baseUrl,
                                           rasProjectId: settings?.rasProjectId,
                                           subscriptionKey: settings?.subscriptionKey,
                                           hostAppVersion: settings?.hostAppVersion,
                                           isPreviewMode: settings?.isPreviewMode)
        self.manifestDownloader = ManifestDownloader()
        self.miniAppStatus = MiniAppStatus()
        self.miniAppPermissionStorage = MiniAppPermissionsStorage()
        self.miniAppManifestStorage = MAManifestStorage()
        self.miniAppDownloader = MiniAppDownloader(apiClient: self.miniAppClient, manifestDownloader: self.manifestDownloader, status: self.miniAppStatus)
        self.displayer = Displayer(navigationSettings)
        self.miniAppAnalyticsConfig = settings?.analyticsConfigList ?? []
    }

    func update(with settings: MiniAppSdkConfig?, navigationSettings: MiniAppNavigationConfig? = nil) {
        self.miniAppClient.updateEnvironment(with: settings)
        self.displayer.navConfig = navigationSettings
        self.miniAppAnalyticsConfig = settings?.analyticsConfigList ?? []
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
    func createMiniApp(appInfo: MiniAppInfo, queryParams: String? = nil, completionHandler: @escaping (Result<MiniAppDisplayDelegate, Error>) -> Void, messageInterface: MiniAppMessageDelegate? = nil, adsDisplayer: MiniAppAdDisplayer? = nil) {
        getMiniApp(miniAppId: appInfo.id, miniAppVersion: appInfo.version.versionId) { (result) in
            switch result {
            case .success(let responseData):
                if appInfo.version.versionId != responseData.version.versionId {
                    self.downloadMiniApp(
                            appInfo: responseData,
                            queryParams: queryParams,
                            completionHandler: completionHandler,
                            messageInterface: messageInterface,
                            adsDisplayer: adsDisplayer)
                    return
                }
                self.downloadMiniApp(
                        appInfo: appInfo,
                        queryParams: queryParams,
                        completionHandler: completionHandler,
                        messageInterface: messageInterface)
            case .failure(let error):
                self.handleMiniAppDownloadError(
                        appId: appInfo.id,
                        error: error,
                        queryParams: queryParams,
                        completionHandler: completionHandler,
                        messageInterface: messageInterface,
                        adsDisplayer: adsDisplayer)
            } }
    }

    func createMiniApp(appId: String, version: String? = nil, queryParams: String? = nil, completionHandler: @escaping (Result<MiniAppDisplayDelegate, MASDKError>) -> Void, messageInterface: MiniAppMessageDelegate? = nil, adsDisplayer: MiniAppAdDisplayer? = nil) {
        getMiniApp(miniAppId: appId, miniAppVersion: version) { (result) in
            switch result {
            case .success(let responseData):
                self.miniAppStatus.saveMiniAppInfo(appInfo: responseData, key: responseData.id)
                self.downloadMiniApp(appInfo: responseData,
                                     queryParams: queryParams,
                                     completionHandler: self.createCompletionHandler(completionHandler: completionHandler),
                                     messageInterface: messageInterface,
                                     adsDisplayer: adsDisplayer)
            case .failure(let error):
                self.handleMiniAppDownloadError(appId: appId,
                                 error: error,
                                 queryParams: queryParams,
                                 completionHandler: self.createCompletionHandler(completionHandler: completionHandler),
                                 messageInterface: messageInterface,
                                 adsDisplayer: adsDisplayer)
            } }
    }

    func createMiniApp(url: URL, queryParams: String? = nil, errorHandler: @escaping (Error) -> Void, messageInterface: MiniAppMessageDelegate? = nil, adsDisplayer: MiniAppAdDisplayer? = nil) -> MiniAppDisplayDelegate {
        displayer.getMiniAppView(miniAppURL: url,
                                 miniAppTitle: "Mini app",
                                 queryParams: queryParams,
                                 hostAppMessageDelegate: messageInterface ?? self,
                                 adsDisplayer: adsDisplayer,
                                 initialLoadCallback: { success in
                                    if !success {
                                        errorHandler(NSError.invalidURLError())
                                    }
                                 }, analyticsConfig: self.miniAppAnalyticsConfig)
    }

    /// Download Mini app for a given Mini app info object
    /// - Parameters:
    ///   - appInfo: Miniapp Info object
    ///   - queryParams: Optional Query parameters that the host app would like to share while creating a mini app
    ///   - completionHandler: Completion Handler that needed to pass back the MiniAppDisplayProtocol
    ///   - messageInterface: Miniapp communication protocol object.
    ///   - adsDisplayer: a MiniAppAdDisplayer that will handle Miniapp ads requests
    func downloadMiniApp(appInfo: MiniAppInfo,
                         queryParams: String? = nil,
                         completionHandler: @escaping (Result<MiniAppDisplayDelegate, Error>) -> Void,
                         messageInterface: MiniAppMessageDelegate? = nil,
                         adsDisplayer: MiniAppAdDisplayer? = nil) {
        return miniAppDownloader.verifyAndDownload(appId: appInfo.id, versionId: appInfo.version.versionId) { (result) in
            switch result {
            case .success:
                self.getMiniAppView(
                        appInfo: appInfo,
                        queryParams: queryParams,
                        completionHandler: completionHandler,
                        messageInterface: messageInterface,
                        adsDisplayer: adsDisplayer)
            case .failure(let error):
                self.handleMiniAppDownloadError(
                        appId: appInfo.id,
                        error: error,
                        queryParams: queryParams,
                        completionHandler: completionHandler,
                        messageInterface: messageInterface,
                        adsDisplayer: adsDisplayer)
            }
        }
    }

    func getMiniAppView(appInfo: MiniAppInfo, queryParams: String? = nil, completionHandler: @escaping (Result<MiniAppDisplayDelegate, Error>) -> Void, messageInterface: MiniAppMessageDelegate? = nil, adsDisplayer: MiniAppAdDisplayer? = nil) {
        self.miniAppStatus.setDownloadStatus(true, appId: appInfo.id, versionId: appInfo.version.versionId)
        self.miniAppStatus.setCachedVersion(appInfo.version.versionId, for: appInfo.id)
        isRequiredPermissionsAllowed(
                appId: appInfo.id,
                versionId: appInfo.version.versionId) { (result) in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    let miniAppDisplayProtocol = self.displayer.getMiniAppView(miniAppId: appInfo.id,
                                                                               versionId: appInfo.version.versionId,
                                                                               projectId: self.miniAppClient.environment.projectId,
                                                                               miniAppTitle: appInfo.displayName ?? "Mini app",
                                                                               queryParams: queryParams,
                                                                               hostAppMessageDelegate: messageInterface ?? self,
                                                                               adsDisplayer: adsDisplayer,
                                                                               analyticsConfig: self.miniAppAnalyticsConfig)
                    completionHandler(.success(miniAppDisplayProtocol))
                }
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }

    func handleMiniAppDownloadError(appId: String,
                                    error: Error,
                                    queryParams: String? = nil,
                                    completionHandler: @escaping (Result<MiniAppDisplayDelegate, Error>) -> Void,
                                    messageInterface: MiniAppMessageDelegate? = nil,
                                    adsDisplayer: MiniAppAdDisplayer? = nil) {
        let downloadError = error as NSError
        if isDeviceOfflineError(error: downloadError) {
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
        let cachedPermissions = miniAppPermissionStorage.getCustomPermissions(forMiniApp: id)
        return filterCustomPermissions(forMiniApp: id, cachedPermissions: cachedPermissions)
    }

    func storeCustomPermissions(forMiniApp id: String, permissionList: [MASDKCustomPermissionModel]) {
        miniAppPermissionStorage.storeCustomPermissions(permissions: permissionList, forMiniApp: id)
    }

    func filterCustomPermissions(forMiniApp id: String, cachedPermissions: [MASDKCustomPermissionModel]) -> [MASDKCustomPermissionModel] {
        guard let manifestData = self.miniAppManifestStorage.getManifestInfo(forMiniApp: id)?.miniAppManifest else {
            return cachedPermissions
        }
        let manifestCustomPermissions = (manifestData.requiredPermissions ?? []) + (manifestData.optionalPermissions ?? [])
        let filtered = cachedPermissions.filter {
            manifestCustomPermissions.contains($0)
        }
        return filtered
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
                                 clearPermissions: Bool = true,
                                 completionHandler: @escaping (Result<MiniAppManifest, MASDKError>) -> Void) {
        if appId.isEmpty {
            return completionHandler(.failure(.invalidAppId))
        }
        if version.isEmpty {
            return completionHandler(.failure(.invalidVersionId))
        }
        metaDataDownloader.getMiniAppMetaInfo(miniAppId: appId,
                                              miniAppVersion: version,
                                              apiClient: self.miniAppClient) { (result) in
            switch result {
            case .success(let metaData):
                if clearPermissions {
                    self.cleanUpCustomPermissions(appId: appId, latestManifest: metaData)
                }
                completionHandler(.success(metaData))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }

    /// In Preview mode, when Codebase is updated, & if there is a change in Manifest, it is good to delete the old Custom Permissions from the Keychain.
    /// Because the user has to agree to the new MiniAppManifest, also this will help to compare the latest manifest.
    func cleanUpCustomPermissions(appId: String, latestManifest: MiniAppManifest) {
        if self.getCachedManifestData(appId: appId) != latestManifest {
            miniAppPermissionStorage.removeKey(for: appId)
        }
    }

    /// Method to remove the unused/deleted items from the Keychain
    func cleanUpKeychain() {
        self.miniAppStatus.removeUnusedCustomPermissions()
    }

    /// Method to check if all the required permissions mentioned in the manifest.json is agreed by the user.
    /// - Parameters:
    ///   - appId: MiniApp ID
    ///   - versionId: Specific VersionID of a MiniApp
    ///   - completionHandler: Handler that returns whether user agreed to required permissions or not.
    func isRequiredPermissionsAllowed(appId: String, versionId: String, completionHandler: @escaping (Result<Bool, MASDKError>) -> Void) {
        let cachedMetaData = self.miniAppManifestStorage.getManifestInfo(forMiniApp: appId)
        if cachedMetaData?.version != versionId || miniAppClient.environment.isPreviewMode {
            retrieveMiniAppMetaData(appId: appId, version: versionId, clearPermissions: false) { (result) in
                switch result {
                case .success(let manifest):
                    self.miniAppManifestStorage.saveManifestInfo(forMiniApp: appId,
                                                                 manifest: CachedMetaData(version: versionId,
                                                                                          miniAppManifest: manifest))
                    self.verifyRequiredPermissions(appId: appId,
                                                   miniAppManifest: manifest,
                                                   completionHandler: completionHandler)
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
        } else {
            self.verifyRequiredPermissions(appId: appId,
                                           miniAppManifest: cachedMetaData?.miniAppManifest,
                                           completionHandler: completionHandler)
        }
    }

    /// Method that compares the required permissions from the manifest and the stored custom permissions.
    /// - Parameters:
    ///   - appId: MiniApp ID
    ///   - requiredPermissions: List of required Custom permissions that is defined by the Mini App
    ///   - completionHandler: Handler that returns whether user agreed to required permissions or not.
    func verifyRequiredPermissions(appId: String,
                                   miniAppManifest: MiniAppManifest?,
                                   completionHandler: @escaping (Result<Bool, MASDKError>) -> Void) {
        guard let manifestData = miniAppManifest, let requiredPermissions = manifestData.requiredPermissions else {
            miniAppPermissionStorage.removeKey(for: appId)
            return completionHandler(.success(true))
        }
        let storedCustomPermissions = self.miniAppPermissionStorage.getCustomPermissions(forMiniApp: appId)
        let filtered = storedCustomPermissions.filter {
            requiredPermissions.contains($0)
        }
        if filtered.allSatisfy({ $0.isPermissionGranted.boolValue == true }) {
            miniAppPermissionStorage.removeKey(for: appId)
            miniAppPermissionStorage.storeCustomPermissions(permissions: filterCustomPermissions(forMiniApp: appId,
                                                                                                 cachedPermissions: storedCustomPermissions),
                                                            forMiniApp: appId)
            completionHandler(.success(true))
        } else {
            completionHandler(.failure(.metaDataFailure))
        }
    }

    /// Method that returns the Cached MiniAppManifest from the Keychain
    /// - Parameter appId: MiniApp ID
    /// - Returns: MiniAppManifest object
    func getCachedManifestData(appId: String) -> MiniAppManifest? {
        return self.miniAppManifestStorage.getManifestInfo(forMiniApp: appId)?.miniAppManifest
    }

    func isDeviceOfflineError(error: NSError) -> Bool {
        if error.domain == MASDKErrorDomain, let maSDKError = error as? MASDKError {
            return maSDKError.isDeviceOfflineDownloadError()
        }
        return offlineErrorCodeList.contains(error.code)
    }
}

extension RealMiniApp: MiniAppMessageDelegate {
    func sendMessageToContact(_ message: MessageToContact, completionHandler: @escaping (Result<String?, MASDKError>) -> Void) {
        completionHandler(.failure(.failedToConformToProtocol))
    }

    func sendMessageToContactId(_ contactId: String, message: MessageToContact, completionHandler: @escaping (Result<String?, MASDKError>) -> Void) {
        completionHandler(.failure(.failedToConformToProtocol))
    }

    func sendMessageToMultipleContacts(_ message: MessageToContact, completionHandler: @escaping (Result<[String]?, MASDKError>) -> Void) {
        completionHandler(.failure(.failedToConformToProtocol))
    }

    func requestCustomPermissions(permissions: [MASDKCustomPermissionModel], completionHandler: @escaping (Result<[MASDKCustomPermissionModel], MASDKCustomPermissionError>) -> Void) {
        completionHandler(.failure(.failedToConformToProtocol))
    }

    func requestDevicePermission(permissionType: MiniAppDevicePermissionType, completionHandler: @escaping (Result<MASDKPermissionResponse, MASDKPermissionError>) -> Void) {
        completionHandler(.failure(.failedToConformToProtocol))
    }

    func shareContent(info: MiniAppShareContent, completionHandler: @escaping (Result<MASDKProtocolResponse, Error>) -> Void) {
        let error: NSError = NSError.init(domain: "MiniAppMessageBridge has not been implemented by the host app", code: 0, userInfo: nil)
        completionHandler(.failure(error as Error))
    }
}
