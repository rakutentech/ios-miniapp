import SwiftUI
import MiniApp

struct MiniAppSingleView: View {
    
    @StateObject var viewModel: MiniAppWithTermsViewModel
    
    @State var miniAppId: String
    @State var miniAppVersion: String?
    @State var miniAppType: MiniAppType
    
    @State private var permissionRequest: MiniAppPermissionRequest? = nil
    @State private var isPermissionPresented: Bool = false
    @State private var didAcceptTerms: Bool = false
    @State private var didAcceptSettingsTerms: Bool = false
    
    init(miniAppId: String, miniAppVersion: String?, miniAppType: MiniAppType) {
        _viewModel = StateObject(wrappedValue: MiniAppWithTermsViewModel(miniAppId: miniAppId, miniAppVersion: miniAppVersion, miniAppType: .miniapp))
        _miniAppId = State(wrappedValue: miniAppId)
        _miniAppVersion = State(wrappedValue: miniAppVersion)
        _miniAppType = State(wrappedValue: miniAppType)
    }
    
    var body: some View {
        VStack {
            MiniAppWithTermsView(viewModel: viewModel)
//            MiniAppWithTermsView(
//                miniAppId: miniAppId,
//                miniAppVersion: miniAppVersion,
//                miniAppType: miniAppType
//            )
        }
        .navigationTitle("MiniApp")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.viewState == .success {
                    Button {
                        openPermissionSettings()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                } else {
                    EmptyView()
                }
            }
        })
        .sheet(item: $permissionRequest, content: { request in
            NavigationView {
                MiniAppTermsView(didAccept: $didAcceptSettingsTerms, request: request)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            permissionRequest = nil
                        } label: {
                            Text("Cancel")
                        }
                    }
                }
            }
        })
        .onChange(of: didAcceptSettingsTerms, perform: { accepted in
            if accepted {
                viewModel.load()
                didAcceptSettingsTerms = false
            }
        })
        .onChange(of: viewModel.viewState) { state in
            print("State Change: ", state)
            switch state {
            case .success:
                self.permissionRequest = nil
            default:
                ()
            }
        }
    }

    func openPermissionSettings() {
        viewModel.fetchPermissionRequest { result in
            switch result {
            case .success(let request):
                permissionRequest = request
                //isPermissionPresented = true
            case .failure(let error):
                viewModel.viewState = .error(error)
            }
        }
    }
}

struct MiniAppSingleView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppSingleView(
            miniAppId: "",
            miniAppVersion: "",
            miniAppType: .miniapp
        )
    }
}

struct MiniAppPermissionRequest: Identifiable {
    let id = UUID()
    let info: MiniAppInfo
    let manifest: MiniAppManifest
}
