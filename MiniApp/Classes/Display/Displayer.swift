internal class Displayer {
    var navConfig: MiniAppNavigationConfig?

    init(_ config: MiniAppNavigationConfig? = nil) {
        self.navConfig = config
    }

    func getMiniAppView(miniAppId: String, versionId: String, miniAppTitle: String, hostAppMessageDelegate: MiniAppMessageDelegate) -> MiniAppDisplayProtocol {
        return RealMiniAppView(
          miniAppId: miniAppId,
          versionId: versionId,
          miniAppTitle: miniAppTitle,
          hostAppMessageDelegate: hostAppMessageDelegate,
          displayNavBar: navConfig?.navigationBarVisibility ?? .never,
          navigationDelegate: navConfig?.navigationDelegate,
          navigationView: navConfig?.navigationView)
    }
}
