import SwiftUI
import MiniApp

struct MiniAppSingleView: View {
    
    @StateObject var viewModel: MiniAppWithTermsViewModel
    
    @Binding var miniAppId: String
    @Binding var miniAppVersion: String?
    @State var miniAppType: MiniAppType
    
    @State private var permissionRequest: MiniAppPermissionRequest? = nil
    @State private var isPermissionPresented: Bool = false
    @State private var didAcceptTerms: Bool = false
    @State private var didAcceptSettingsTerms: Bool = false
    
    init(miniAppId: Binding<String>, miniAppVersion: Binding<String?>, miniAppType: MiniAppType) {
        _viewModel = StateObject(wrappedValue: MiniAppWithTermsViewModel(miniAppId: miniAppId.wrappedValue, miniAppVersion: miniAppVersion.wrappedValue, miniAppType: .miniapp))
        _miniAppId = miniAppId
        _miniAppVersion = miniAppVersion
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
        .sheet(isPresented: $isPermissionPresented, content: {
            if let permissionRequest = permissionRequest {
                NavigationView {
                    MiniAppTermsView(didAccept: $didAcceptSettingsTerms, request: permissionRequest)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                isPermissionPresented = false
                            } label: {
                                Text("Cancel")
                            }
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
                self.isPermissionPresented = false
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
                isPermissionPresented = true
            case .failure(let error):
                viewModel.viewState = .error(error)
            }
        }
    }
}

struct MiniAppSingleView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppSingleView(
            miniAppId: .constant(""),
            miniAppVersion: .constant(""),
            miniAppType: .miniapp
        )
    }
}

struct MiniAppPermissionRequest: Identifiable {
    let id = UUID()
    let info: MiniAppInfo
    let manifest: MiniAppManifest
}
