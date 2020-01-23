internal class RealMiniApp {
    static let shared =  RealMiniApp()
    var environment: Environment
    var miniAppLister: MiniAppLister

    init() {
        self.environment = Environment()
        self.miniAppLister = MiniAppLister(environment: environment)
    }

    func listMiniApp(completionHandler: @escaping (Result<[MiniAppInfo], Error>) -> Void) {
        return miniAppLister.fetchList(completionHandler: completionHandler)
    }

    func createMiniApp(appId: String, completionHandler: @escaping (Result<MiniAppView, Error>) -> Void) {
    }
}
