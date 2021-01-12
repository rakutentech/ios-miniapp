internal class Displayer {
    var navConfig: MiniAppNavigationConfig?

    init(_ config: MiniAppNavigationConfig? = nil) {
        self.navConfig = config
    }

    func getMiniAppView(miniAppId: String,
                        versionId: String,
                        projectId: String,
                        miniAppTitle: String,
                        hostAppMessageDelegate: MiniAppMessageDelegate) -> MiniAppDisplayProtocol {
        return RealMiniAppView(
          miniAppId: miniAppId,
          versionId: versionId,
          projectId: projectId,
          miniAppTitle: miniAppTitle,
          hostAppMessageDelegate: hostAppMessageDelegate,
          displayNavBar: navConfig?.navigationBarVisibility ?? .never,
          navigationDelegate: navConfig?.navigationDelegate,
          navigationView: navConfig?.navigationView)
    }

    func getMiniAppView(miniAppURL: URL,
                        miniAppTitle: String,
                        hostAppMessageDelegate: MiniAppMessageDelegate,
                        initialLoadCallback: @escaping (Bool) -> Void) -> MiniAppDisplayProtocol {
        return RealMiniAppView(
          miniAppURL: miniAppURL,
          miniAppTitle: miniAppTitle,
          hostAppMessageDelegate: hostAppMessageDelegate,
          initialLoadCallback: initialLoadCallback,
          displayNavBar: navConfig?.navigationBarVisibility ?? .never,
          navigationDelegate: navConfig?.navigationDelegate,
          navigationView: navConfig?.navigationView)
    }
}
