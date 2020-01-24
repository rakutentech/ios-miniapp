internal class RealMiniApp {
    static let shared =  RealMiniApp()
    var miniAppLister: MiniAppLister
    var miniAppClient: MiniAppClient

    init() {
        self.miniAppLister = MiniAppLister()
        self.miniAppClient = MiniAppClient()
    }

    func listMiniApp(completionHandler: @escaping (Result<[MiniAppInfo], Error>) -> Void) {
        return miniAppLister.fetchList(apiClient: self.miniAppClient, completionHandler: completionHandler)
    }

    func createMiniApp(appId: String, completionHandler: @escaping (Result<MiniAppView, Error>) -> Void) {
    }
}
