import SwiftUI
import MiniApp

struct MiniAppWithTermsView: View {

    @ObservedObject var viewModel: MiniAppWithTermsViewModel

    @State private var didAcceptTerms: Bool = false
    @State private var showMessageAlert: Bool = false
//    init(miniAppId: String, miniAppVersion: String? = nil, miniAppType: MiniAppType = .miniapp) {
//        _viewModel = StateObject(wrappedValue:
//            MiniAppWithTermsViewModel(miniAppId: miniAppId, miniAppVersion: miniAppVersion, miniAppType: miniAppType)
//        )
//    }

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
                    request: MiniAppPermissionRequest(info: info, manifest: manifest)
                )
            case .error(let error):
                Text(error.localizedDescription)
                    .font(.system(size: 14, weight: .medium))
                    .padding(.horizontal, 40)
            case .success:
                MiniAppSUView(params:
                    MiniAppViewDefaultParams(
                        config: MiniAppConfig(
                            config: Config.current(),
                            adsDisplayer: nil,
                            messageInterface: viewModel.messageInterface
                        ),
                        type: viewModel.miniAppType,
                        appId: viewModel.miniAppId,
                        version: viewModel.miniAppVersion
                    )
                )
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
}

struct MiniAppWithTermsView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppWithTermsView(viewModel: MiniAppWithTermsViewModel(miniAppId: ""))
    }
}

public extension ShapeStyle where Self == Color {
    static var debug: Color {
    #if DEBUG
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        ).opacity(0.7)
    #else
        return Color(.clear)
    #endif
    }
}
