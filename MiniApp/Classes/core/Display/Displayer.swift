internal class Displayer {
    var navConfig: MiniAppNavigationConfig?

    init(_ config: MiniAppNavigationConfig? = nil) {
        self.navConfig = config
    }
    func getMiniAppView(miniAppId: String,
                        versionId: String,
                        projectId: String,
                        miniAppTitle: String,
                        miniAppScopes: [MASDKAccessTokenPermission]? = nil,
                        queryParams: String? = nil,
                        hostAppMessageDelegate: MiniAppMessageDelegate,
                        adsDisplayer: MiniAppAdDisplayer? = nil) -> MiniAppDisplayDelegate {
        RealMiniAppView(
          miniAppId: miniAppId,
          versionId: versionId,
          projectId: projectId,
          miniAppScopes: miniAppScopes,
          miniAppTitle: miniAppTitle,
          queryParams: queryParams,
          hostAppMessageDelegate: hostAppMessageDelegate,
          adsDisplayer: adsDisplayer,
          displayNavBar: navConfig?.navigationBarVisibility ?? .never,
          navigationDelegate: navConfig?.navigationDelegate,
          navigationView: navConfig?.navigationView)
    }

    func getMiniAppView(miniAppURL: URL,
                        miniAppTitle: String,
                        miniAppScopes: [MASDKAccessTokenPermission]? = nil,
                        queryParams: String? = nil,
                        hostAppMessageDelegate: MiniAppMessageDelegate,
                        adsDisplayer: MiniAppAdDisplayer? = nil,
                        initialLoadCallback: @escaping (Bool) -> Void) -> MiniAppDisplayDelegate {
        RealMiniAppView(
            miniAppURL: miniAppURL,
            miniAppTitle: miniAppTitle,
            miniAppScopes: miniAppScopes,
            queryParams: queryParams,
            hostAppMessageDelegate: hostAppMessageDelegate,
            adsDisplayer: adsDisplayer,
            initialLoadCallback: initialLoadCallback,
            displayNavBar: navConfig?.navigationBarVisibility ?? .never,
            navigationDelegate: navConfig?.navigationDelegate,
            navigationView: navConfig?.navigationView)
    }
}
