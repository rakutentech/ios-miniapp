internal class Displayer {
    var navConfig: MiniAppNavigationConfig?

    init(_ config: MiniAppNavigationConfig? = nil) {
        self.navConfig = config
    }

    func getMiniAppView(miniAppId: String, versionId: String, hostAppMessageDelegate: MiniAppMessageProtocol) -> MiniAppDisplayProtocol {
        return RealMiniAppView(
            miniAppId: miniAppId,
            versionId: versionId,
            hostAppMessageDelegate: hostAppMessageDelegate,
            displayNavBar: navConfig?.navigationBarVisibility ?? .never,
            navigationDelegate: navConfig?.navigationDelegate,
            navigationView: navConfig?.navigationView)
    }
}
