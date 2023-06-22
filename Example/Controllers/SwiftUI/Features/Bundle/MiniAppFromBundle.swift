import SwiftUI
import MiniApp

struct MiniAppFromBundle: View {

    @State var isMiniAppLoading: Bool = false

    var body: some View {
        VStack {
            MiniAppSUIView(params: miniAppViewParams(config: ListConfiguration(listType: .listI).sdkConfig), fromCache: true, handler: MiniAppSUIViewHandler(), fromBundle: true)
        }
        .navigationTitle("MiniApp")
    }
    
    func miniAppViewParams(config: MiniAppSdkConfig) -> MiniAppViewParameters.DefaultParams {
        return MiniAppViewParameters.DefaultParams.init(
            config: MiniAppConfig(
                config: config,
                adsDisplayer: AdMobDisplayer(),
                messageDelegate: MiniAppViewMessageDelegator(),
                navigationDelegate: MiniAppViewNavigationDelegator()
            ),
            type: .miniapp,
            appId: "mini-app-testing-appid",
            version: "mini-app-testing-versionid",
            queryParams: getQueryParam()
        )
    }
}
