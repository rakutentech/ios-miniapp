import SwiftUI
import MiniApp

struct MiniAppWithTermsView: View {

    @StateObject var keyboardHelper = KeyboardNotificationHelper()

    @ObservedObject var viewModel: MiniAppWithTermsViewModel
    @ObservedObject var handler = MiniAppSUIViewHandler()

    @State private var didAcceptTerms: Bool = false
    @State private var showMessageAlert: Bool = false
    @State private var showJsonStringAlert: Bool = false

    var body: some View {
        if #available(iOS 15.0, *) {
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
                        .foregroundColor(Color(UIColor.secondaryLabel))
                        .font(.system(size: 14, weight: .medium))
                        .padding(.horizontal, 40)
                case .offline:
                    MiniAppSUIView(params: miniAppViewParams(config: viewModel.sdkConfig), fromCache: true, handler: handler)
                case .success:
                    MiniAppSUIView(params: miniAppViewParams(config: viewModel.sdkConfig), fromCache: false, handler: handler)
                }
            }
            .onChange(of: didAcceptTerms, perform: { accepted in
                if accepted {
                    viewModel.viewState = .success
                }
            })
            .onReceive(viewModel.showMessageAlert) {
                showMessageAlert = $0
            }
            .onChange(of: viewModel.viewState) { newValue in
                switch newValue {
                case .success:
                    viewModel.addHandlerToList(handler)
                default:
                    print("No Handler to passs")
                }
            }.alert(Text(viewModel.showJsonString != nil ? "Universal Bridge" : "Info"), isPresented: $showMessageAlert) {
                Button("OK") {
                    viewModel.showMessageAlert.send(false)
                }
            } message: {
                if let message = viewModel.showJsonString {
                    Text(message)
                } else {
                    Text("Message sent!")
                }
                }
        } else {
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
                        .foregroundColor(Color(UIColor.secondaryLabel))
                        .font(.system(size: 14, weight: .medium))
                        .padding(.horizontal, 40)
                case .offline:
                    MiniAppSUIView(params: miniAppViewParams(config: viewModel.sdkConfig), fromCache: true, handler: handler)
                case .success:
                    MiniAppSUIView(params: miniAppViewParams(config: viewModel.sdkConfig), fromCache: false, handler: handler)
                }
            }
            .alert(isPresented: $showMessageAlert) {
                if let message = viewModel.showJsonString {
                    return Alert(
                        title: Text("Universal Bridge"),
                        message: Text(message),
                        dismissButton: Alert.Button.cancel(Text("Ok"), action: {
                            viewModel.showMessageAlert.send(false)
                        }))
                } else {
                    return Alert(
                        title: Text("Info"),
                        message: Text("Message sent!"),
                        dismissButton: Alert.Button.cancel(Text("Ok"), action: {
                            viewModel.showMessageAlert.send(false)
                        }))
                }
            }
            .onChange(of: didAcceptTerms, perform: { accepted in
                if accepted {
                    viewModel.viewState = .success
                }
            })
            .onReceive(viewModel.showMessageAlert) {
                showMessageAlert = $0
            }
            .onChange(of: viewModel.viewState) { newValue in
                switch newValue {
                case .success:
                    viewModel.addHandlerToList(handler)
                default:
                    print("No Handler to passs")
                }
            }
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
        MiniAppWithTermsView(viewModel: MiniAppWithTermsViewModel(miniAppId: "", listType: .listI))
    }
}
