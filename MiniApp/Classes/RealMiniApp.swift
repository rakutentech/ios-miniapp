internal class RealMiniApp {
    static let shared =  RealMiniApp()
    var environment: Environment

    init() {
        self.environment = Environment()
    }

    func listMiniApp(completionHandler: @escaping (Result<[MiniAppInfo], Error>) -> Void) {
    }

    func createMiniApp(appId: String, completionHandler: @escaping (Result<MiniAppView, Error>) -> Void) {
    }
}
