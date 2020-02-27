internal class RealMiniApp {
    static let shared =  RealMiniApp()
    var miniAppInfoFetcher: MiniAppInfoFetcher
    var miniAppClient: MiniAppClient
    var miniAppDownloader: MiniAppDownloader
    var manifestDownloader: ManifestDownloader
    var displayer: Displayer

    init() {
        self.miniAppInfoFetcher = MiniAppInfoFetcher()
        self.miniAppClient = MiniAppClient()
        self.manifestDownloader = ManifestDownloader()
        self.miniAppDownloader = MiniAppDownloader(apiClient: self.miniAppClient, manifestDownloader: self.manifestDownloader)
        self.displayer = Displayer()
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
                case .success:
                    guard let miniAppPath = FileManager.getMiniAppDirectory(with: appInfo.id, and: appInfo.version.versionId) else {
                        completionHandler(.failure(NSError.downloadingFailed()))
                        return
                    }
                    DispatchQueue.main.async {
                        guard let miniAppDisplayProtocol = self.displayer.getMiniAppView(miniAppPath: miniAppPath) else {
                            completionHandler(.failure(NSError.downloadingFailed()))
                            return
                        }
                        completionHandler(.success(miniAppDisplayProtocol))
                    }
                case .failure(let error):
                    completionHandler(.failure(error))
            }
        }
    }
}
