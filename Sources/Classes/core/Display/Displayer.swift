import Foundation

internal class Displayer {
    var sdkConfig: MiniAppSdkConfig?
    var navConfig: MiniAppNavigationConfig?

    init(_ sdkConfig: MiniAppSdkConfig? = nil, _ navConfig: MiniAppNavigationConfig? = nil) {
        self.sdkConfig = sdkConfig
        self.navConfig = navConfig
    }

    func getMiniAppView(miniAppId: String,
                        versionId: String,
                        projectId: String,
                        miniAppTitle: String,
                        queryParams: String? = nil,
                        hostAppMessageDelegate: MiniAppMessageDelegate,
                        adsDisplayer: MiniAppAdDisplayer? = nil,
                        analyticsConfig: [MAAnalyticsConfig]? = []) -> MiniAppDisplayDelegate {
        RealMiniAppView(
          miniAppId: miniAppId,
          versionId: versionId,
          projectId: projectId,
          miniAppTitle: miniAppTitle,
          queryParams: queryParams,
          hostAppMessageDelegate: hostAppMessageDelegate,
          adsDisplayer: adsDisplayer,
          displayNavBar: navConfig?.navigationBarVisibility ?? .never,
          navigationDelegate: navConfig?.navigationDelegate,
          navigationView: navConfig?.navigationView,
          analyticsConfig: analyticsConfig,
          storageMaxSizeInBytes: sdkConfig?.storageMaxSizeInBytes
        )
    }

    func getMiniAppView(miniAppURL: URL,
                        miniAppTitle: String,
                        queryParams: String? = nil,
                        hostAppMessageDelegate: MiniAppMessageDelegate,
                        adsDisplayer: MiniAppAdDisplayer? = nil,
                        initialLoadCallback: @escaping (Bool) -> Void,
                        analyticsConfig: [MAAnalyticsConfig]? = []) -> MiniAppDisplayDelegate {
        RealMiniAppView(
            miniAppURL: miniAppURL,
            miniAppTitle: miniAppTitle,
            queryParams: queryParams,
            hostAppMessageDelegate: hostAppMessageDelegate,
            adsDisplayer: adsDisplayer,
            initialLoadCallback: initialLoadCallback,
            displayNavBar: navConfig?.navigationBarVisibility ?? .never,
            navigationDelegate: navConfig?.navigationDelegate,
            navigationView: navConfig?.navigationView,
            analyticsConfig: analyticsConfig,
            storageMaxSizeInBytes: sdkConfig?.storageMaxSizeInBytes
        )
    }
}
