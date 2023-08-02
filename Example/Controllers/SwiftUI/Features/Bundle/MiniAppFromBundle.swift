import SwiftUI
import MiniApp

struct MiniAppFromBundle: View {

    @State var isMiniAppLoading: Bool = false

    var body: some View {
        VStack {
            MiniAppSUIView(params: miniAppViewParams(config: ListConfiguration(listType: .listI).sdkConfig), fromCache: true, handler: MiniAppSUIViewHandler(), fromBundle: true)
        }
        .navigationTitle(MiniAppSDKConstants.miniAppRootFolderName)
    }

    func miniAppViewParams(config: MiniAppSdkConfig) -> MiniAppViewParameters.DefaultParams {
        return MiniAppViewParameters.DefaultParams.init(
            config: MiniAppConfig(
                config: config,
                adsDisplayer: AdMobDisplayer(),
                messageDelegate: MiniAppViewMessageDelegator(miniAppId: Global.DemoApp.bundleMiniAppId,
                                                             miniAppVersion: Global.DemoApp.bundleMiniAppVersionId),
                navigationDelegate: MiniAppViewNavigationDelegator()
            ),
            type: .miniapp,
            appId: Global.DemoApp.bundleMiniAppId,
            version: Global.DemoApp.bundleMiniAppVersionId,
            queryParams: getQueryParam()
        )
    }
}
