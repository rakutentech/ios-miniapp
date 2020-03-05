internal class RealMiniApp {
    static let shared = RealMiniApp()
    static var instances = [String: RealMiniApp]()
    var miniAppInfoFetcher: MiniAppInfoFetcher
    var miniAppClient: MiniAppClient
    var miniAppDownloader: MiniAppDownloader
    var manifestDownloader: ManifestDownloader
    var displayer: Displayer
    var miniAppStatus: MiniAppStatus

    convenience init() {
        self.init(with: nil)
    }

    init(with settings: MiniApp.SdkConfig?) {
        self.miniAppInfoFetcher = MiniAppInfoFetcher()
        self.miniAppClient = MiniAppClient(baseUrl: settings?.baseUrl, rasAppId: settings?.rasAppId, subscriptionKey: settings?.subscriptionKey, hostAppVersion: settings?.hostAppVersion)
        self.manifestDownloader = ManifestDownloader()
        self.miniAppStatus = MiniAppStatus()
        self.miniAppDownloader = MiniAppDownloader(apiClient: self.miniAppClient, manifestDownloader: self.manifestDownloader, status: self.miniAppStatus)
        self.displayer = Displayer()
    }

    class func shared(with settings: MiniApp.SdkConfig?) -> RealMiniApp {
        guard let config = settings else {
            return shared
        }

        let instance = instances[config.key] ?? RealMiniApp(with: settings)

        return instance
    }

    func listMiniApp(completionHandler: @escaping (Result<[MiniAppInfo], Error>) -> Void) {
        return miniAppInfoFetcher.fetchList(apiClient: self.miniAppClient, completionHandler: completionHandler)
    }

    func getMiniApp(miniAppId: String, completionHandler: @escaping (Result<MiniAppInfo, Error>) -> Void) {
        return miniAppInfoFetcher.getInfo(miniAppId: miniAppId, apiClient: self.miniAppClient, completionHandler: completionHandler)
    }

    func createMiniApp(appInfo: MiniAppInfo, completionHandler: @escaping (Result<MiniAppDisplayProtocol, Error>) -> Void) {
        return miniAppDownloader.download(appId: appInfo.id, versionId: appInfo.version.versionId) { (result) in
            switch result {
            case .success(let miniAppPath):
                DispatchQueue.main.async {
                    guard let miniAppDisplayProtocol = self.displayer.getMiniAppView(miniAppPath: miniAppPath) else {
                        completionHandler(.failure(NSError.downloadingFailed()))
                        return
                    }
                    self.miniAppStatus.setDownloadStatus(value: true, key: "\(appInfo.id)/\(appInfo.version.versionId)")
                    completionHandler(.success(miniAppDisplayProtocol))
                }
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
}
