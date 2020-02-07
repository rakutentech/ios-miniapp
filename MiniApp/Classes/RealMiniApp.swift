internal class RealMiniApp {
    static let shared =  RealMiniApp()
    var miniAppLister: MiniAppLister
    var miniAppClient: MiniAppClient
    var miniAppDownloader: MiniAppDownloader
    var manifestDownloader: ManifestDownloader


    init() {
        self.miniAppLister = MiniAppLister()
        self.miniAppClient = MiniAppClient()
        self.manifestDownloader = ManifestDownloader()
        self.miniAppDownloader = MiniAppDownloader(apiClient: self.miniAppClient, manifestDownloader: self.manifestDownloader)
    }

    func listMiniApp(completionHandler: @escaping (Result<[MiniAppInfo], Error>) -> Void) {
        return miniAppLister.fetchList(apiClient: self.miniAppClient, completionHandler: completionHandler)
    }

    func createMiniApp(appId: String, completionHandler: @escaping (Result<MiniAppView, Error>) -> Void) {
    }
}
