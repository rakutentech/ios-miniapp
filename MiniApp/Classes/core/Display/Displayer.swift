internal class Displayer {
    var navConfig: MiniAppNavigationConfig?

    init(_ config: MiniAppNavigationConfig? = nil) {
        self.navConfig = config
    }

    func getMiniAppView(miniAppId: String,
                        versionId: String,
                        projectId: String,
                        miniAppTitle: String,
                        queryParams: String? = nil,
                        hostAppMessageDelegate: MiniAppMessageDelegate,
                        adsDelegate: MiniAppAdDisplayDelegate? = nil) -> MiniAppDisplayProtocol {
        return RealMiniAppView(
          miniAppId: miniAppId,
          versionId: versionId,
          projectId: projectId,
          miniAppTitle: miniAppTitle,
          queryParams: queryParams,
          hostAppMessageDelegate: hostAppMessageDelegate,
          adsDelegate: adsDelegate,
          displayNavBar: navConfig?.navigationBarVisibility ?? .never,
          navigationDelegate: navConfig?.navigationDelegate,
          navigationView: navConfig?.navigationView)
    }

    func getMiniAppView(miniAppURL: URL,
                        miniAppTitle: String,
                        queryParams: String? = nil,
                        hostAppMessageDelegate: MiniAppMessageDelegate,
                        adsDelegate: MiniAppAdDisplayDelegate? = nil,
                        initialLoadCallback: @escaping (Bool) -> Void) -> MiniAppDisplayProtocol {
        return RealMiniAppView(
            miniAppURL: miniAppURL,
            miniAppTitle: miniAppTitle,
            queryParams: queryParams,
            hostAppMessageDelegate: hostAppMessageDelegate,
            adsDelegate: adsDelegate,
            initialLoadCallback: initialLoadCallback,
            displayNavBar: navConfig?.navigationBarVisibility ?? .never,
            navigationDelegate: navConfig?.navigationDelegate,
            navigationView: navConfig?.navigationView)
    }
}
