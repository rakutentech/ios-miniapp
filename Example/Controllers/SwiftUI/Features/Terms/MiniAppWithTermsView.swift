import SwiftUI
import MiniApp

struct MiniAppWithTermsView: View {
    
    @StateObject var store: MiniAppPermissionStore = MiniAppPermissionStore()

    @Binding var miniAppId: String
    @Binding var miniAppVersion: String?
    @State var miniAppType: MiniAppType
    
    @State var didAcceptTerms: Bool = false
    
    var body: some View {
        VStack {
            switch store.viewState {
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
                        config: MiniAppNewConfig(
                            config: Config.current(),
                            adsDisplayer: nil,
                            messageInterface: MiniAppViewDelegator(miniAppId: _miniAppId.wrappedValue)
                        ),
                        type: miniAppType,
                        appId: miniAppId,
                        version: miniAppVersion
                    )
                )
            }
        }
        .onAppear(perform: {
            load()
        })
        .onChange(of: didAcceptTerms, perform: { accepted in
            if accepted {
                store.viewState = .success
            }
        })
    }

    func load() {
        DispatchQueue.main.async {
            store.checkPermissions(
                miniAppId: miniAppId,
                miniAppVersion: miniAppVersion ?? ""
            )
        }
    }
}

struct MiniAppWithTermsView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppWithTermsView(miniAppId: .constant(""), miniAppVersion: .constant(""), miniAppType: .miniapp)
    }
}
