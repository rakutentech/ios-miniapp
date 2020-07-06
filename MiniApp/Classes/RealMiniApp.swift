internal class RealMiniApp {
    var miniAppInfoFetcher: MiniAppInfoFetcher
    var miniAppClient: MiniAppClient
    var miniAppDownloader: MiniAppDownloader
    var manifestDownloader: ManifestDownloader
    var displayer: Displayer
    var miniAppStatus: MiniAppStatus
    let offlineErrorCodeList: [Int] = [NSURLErrorNotConnectedToInternet, NSURLErrorTimedOut]

    convenience init() {
        self.init(with: nil)
    }

    init(with settings: MiniAppSdkConfig?) {
        self.miniAppInfoFetcher = MiniAppInfoFetcher()
        self.miniAppClient = MiniAppClient(baseUrl: settings?.baseUrl, rasAppId: settings?.rasAppId, subscriptionKey: settings?.subscriptionKey, hostAppVersion: settings?.hostAppVersion)
        self.manifestDownloader = ManifestDownloader()
        self.miniAppStatus = MiniAppStatus()
        self.miniAppDownloader = MiniAppDownloader(apiClient: self.miniAppClient, manifestDownloader: self.manifestDownloader, status: self.miniAppStatus)
        self.displayer = Displayer()
    }

    func update(with settings: MiniAppSdkConfig?) {
        self.miniAppClient.updateEnvironment(with: settings)
    }

    func listMiniApp(completionHandler: @escaping (Result<[MiniAppInfo], Error>) -> Void) {
        return miniAppInfoFetcher.fetchList(apiClient: self.miniAppClient, completionHandler: completionHandler)
    }

    func getMiniApp(miniAppId: String, completionHandler: @escaping (Result<MiniAppInfo, Error>) -> Void) {
        return miniAppInfoFetcher.getInfo(miniAppId: miniAppId, apiClient: self.miniAppClient, completionHandler: completionHandler)
    }

    /// For a given Miniapp info object, this method will check whether the version id is the latest one with the platform.
    /// If the versions doesn't match it will start downloading the latest version, if the versions match the same object
    /// will be passed on to Downloader class (which will check whether the mini app is downloaded already if not, it will download)
    /// - Parameters:
    ///   - appInfo: Miniapp Info object
    ///   - completionHandler: Completion Handler that needed to pass back the MiniAppDisplayProtocol
    ///   - messageInterface: Miniapp communication protocol object.
    func createMiniApp(appInfo: MiniAppInfo, completionHandler: @escaping (Result<MiniAppDisplayProtocol, Error>) -> Void, messageInterface: MiniAppMessageProtocol? = nil) {
        getMiniApp(miniAppId: appInfo.id) { (result) in
            switch result {
            case .success(let responseData):
                if appInfo.version.versionId != responseData.version.versionId {
                    self.downloadMiniApp(appInfo: responseData, completionHandler: completionHandler, messageInterface: messageInterface)
                    return
                }
                self.downloadMiniApp(appInfo: appInfo, completionHandler: completionHandler, messageInterface: messageInterface)
            case .failure(let error):
                self.handleError(appId: appInfo.id, versionId: appInfo.version.versionId, error: error, completionHandler: completionHandler, messageInterface: messageInterface)
        }}
    }

    /// Download Mini app for a given Mini app info object
    /// - Parameters:
    ///   - appInfo: Miniapp Info object
    ///   - completionHandler: Completion Handler that needed to pass back the MiniAppDisplayProtocol
    ///   - messageInterface: Miniapp communication protocol object.
    func downloadMiniApp(appInfo: MiniAppInfo, completionHandler: @escaping (Result<MiniAppDisplayProtocol, Error>) -> Void, messageInterface: MiniAppMessageProtocol? = nil) {
        return miniAppDownloader.download(appId: appInfo.id, versionId: appInfo.version.versionId) { (result) in
            switch result {
            case .success:
                self.getMiniAppView(appInfo: appInfo, completionHandler: completionHandler, messageInterface: messageInterface)
            case .failure(let error):
                self.handleError(appId: appInfo.id, versionId: appInfo.version.versionId, error: error, completionHandler: completionHandler, messageInterface: messageInterface)
            }
        }
    }

    func getMiniAppView(appInfo: MiniAppInfo, completionHandler: @escaping (Result<MiniAppDisplayProtocol, Error>) -> Void, messageInterface: MiniAppMessageProtocol? = nil) {
        DispatchQueue.main.async {
            let miniAppDisplayProtocol = self.displayer.getMiniAppView(miniAppId: appInfo.id, versionId: appInfo.version.versionId, hostAppMessageDelegate: messageInterface ?? self)
            self.miniAppStatus.setDownloadStatus(true, appId: appInfo.id, versionId: appInfo.version.versionId)
            self.miniAppStatus.setCachedVersion(appInfo.version.versionId, for: appInfo.id)
            completionHandler(.success(miniAppDisplayProtocol))
        }
    }

    func handleError(appId: String, versionId: String, error: Error, completionHandler: @escaping (Result<MiniAppDisplayProtocol, Error>) -> Void, messageInterface: MiniAppMessageProtocol? = nil) {
        let downloadError = error as NSError
        if self.offlineErrorCodeList.contains(downloadError.code) {
            guard let cachedVersion = miniAppDownloader.getCachedMiniAppVersion(appId: appId, versionId: versionId) else {
                return completionHandler(.failure(downloadError))
            }
            DispatchQueue.main.async {
                let miniAppDisplayProtocol = self.displayer.getMiniAppView(miniAppId: appId, versionId: cachedVersion, hostAppMessageDelegate: messageInterface ?? self)
                completionHandler(.success(miniAppDisplayProtocol))
            }
        }
        return completionHandler(.failure(error))
    }
}

extension RealMiniApp: MiniAppMessageProtocol {
    func requestPermission(permissionType: MiniAppPermissionType, completionHandler: @escaping (Result<String, Error>) -> Void) {
        let error: NSError = NSError.init(domain: "MiniAppMessageBridge has not been implemented by the host app", code: 0, userInfo: nil)
        completionHandler(.failure(error as Error))
    }

    func getUniqueId() -> String {
        return "MiniAppMessageBridge has not been implemented by the host app"
    }
}
