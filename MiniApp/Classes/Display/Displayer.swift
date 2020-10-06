internal class Displayer {
    var navConfig: MiniAppNavigationConfig?

    init(_ config: MiniAppNavigationConfig? = nil) {
        self.navConfig = config
    }

    func getMiniAppView(miniAppId: String,
                        versionId: String,
                        miniAppTitle: String,
                        hostAppMessageDelegate: MiniAppMessageProtocol,
                        hostAppUserInfoProtocol: MiniAppUserInfoProtocol) -> MiniAppDisplayProtocol {
        return RealMiniAppView(
          miniAppId: miniAppId,
          versionId: versionId,
          miniAppTitle: miniAppTitle,
          hostAppMessageDelegate: hostAppMessageDelegate, hostAppUserInfoDelegate: hostAppUserInfoProtocol,
          displayNavBar: navConfig?.navigationBarVisibility ?? .never,
          navigationDelegate: navConfig?.navigationDelegate,
          navigationView: navConfig?.navigationView)
    }
}
