internal class RealMiniApp {
    static let shared =  RealMiniApp()
    var miniAppLister: MiniAppLister
    var miniAppClient: MiniAppClient
    var miniAppDownloader: MiniAppDownloader
    var manifestDownloader: ManifestDownloader
    var displayer: Displayer

    init() {
        self.miniAppLister = MiniAppLister()
        self.miniAppClient = MiniAppClient()
        self.manifestDownloader = ManifestDownloader()
        self.miniAppDownloader = MiniAppDownloader(apiClient: self.miniAppClient, manifestDownloader: self.manifestDownloader)
        self.displayer = Displayer()
    }

    func listMiniApp(completionHandler: @escaping (Result<[MiniAppInfo], Error>) -> Void) {
        return miniAppLister.fetchList(apiClient: self.miniAppClient, completionHandler: completionHandler)
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
