import SwiftUI
import MiniApp

struct MiniAppWithTermsView: View {

    @StateObject var keyboardHelper = KeyboardNotificationHelper()

    @ObservedObject var viewModel: MiniAppWithTermsViewModel
    @ObservedObject var handler = MiniAppSUIViewHandler()

    @State private var didAcceptTerms: Bool = false
    @State private var showMessageAlert: Bool = false

    var body: some View {
        VStack {
            switch viewModel.viewState {
            case .none:
                EmptyView()
            case .loading:
                ProgressView()
            case let .permissionRequested(info, manifest):
                MiniAppTermsView(
                    didAccept: $didAcceptTerms,
                    request: MiniAppPermissionRequest(sdkConfig: viewModel.sdkConfig, info: info, manifest: manifest)
                )
            case .error(let error):
                Text(error.localizedDescription)
                    .font(.system(size: 14, weight: .medium))
                    .padding(.horizontal, 40)
            case .offline:
                MiniAppSUIView(params: miniAppViewParams(config: viewModel.sdkConfigProduction), fromCache: true, handler: handler)
            case .success:
                MiniAppSUIView(params: miniAppViewParams(config: viewModel.sdkConfig), fromCache: false, handler: handler)
            }
        }
        .alert(isPresented: $showMessageAlert) {
            Alert(
                title: Text("Info"),
                message: Text("Message sent!"),
                dismissButton: Alert.Button.cancel(Text("Ok"), action: {
                    viewModel.showMessageAlert.send(false)
            }))
        }
        .onChange(of: didAcceptTerms, perform: { accepted in
            if accepted {
                viewModel.viewState = .success
            }
        })
        .onReceive(viewModel.showMessageAlert) {
            showMessageAlert = $0
        }
    }

    func miniAppViewParams(config: MiniAppSdkConfig) -> MiniAppViewParameters.DefaultParams {
        return MiniAppViewParameters.DefaultParams.init(
            config: MiniAppConfig(
                config: config,
                adsDisplayer: AdMobDisplayer(),
                messageDelegate: viewModel.messageInterface,
                navigationDelegate: viewModel.navigationDelegate
            ),
            type: viewModel.miniAppType,
            appId: viewModel.miniAppId,
            version: viewModel.miniAppVersion,
            queryParams: getQueryParam()
        )
    }
}

struct MiniAppWithTermsView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppWithTermsView(viewModel: MiniAppWithTermsViewModel(miniAppId: "", sdkConfig: Config.sampleSdkConfig()))
    }
}
