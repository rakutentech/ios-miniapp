import SwiftUI
import MiniApp

struct MiniAppSingleView: View {

    @StateObject var store: MiniAppPermissionStore = MiniAppPermissionStore()

    @Binding var miniAppId: String
    @Binding var miniAppVersion: String?
    @State var miniAppType: MiniAppType
    
    @State var permissionRequest: MiniAppPermissionRequest? = nil
    @State var isPermissionPresented: Bool = false
    
    @State var didAcceptTerms: Bool = false
    
    var body: some View {
        VStack {
            switch store.viewState {
            case .none:
                EmptyView()
            case .loading:
                ProgressView()
            case let .permissionRequested(info, manifest):
                MiniAppTermsView(didAccept: $didAcceptTerms, request: MiniAppPermissionRequest(info: info, manifest: manifest))
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
        .navigationTitle("MiniApp")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing) {
                if store.viewState == .success {
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
        .onAppear(perform: {
            load()
        })
        .sheet(isPresented: $isPermissionPresented, content: {
            MiniAppPermissionView(request: $permissionRequest, isPresented: $isPermissionPresented)
                .environmentObject(store)
        })
        .onChange(of: didAcceptTerms, perform: { accepted in
            if accepted {
                store.viewState = .success
            }
        })
        .onChange(of: store.viewState) { state in
            print("State Change: ", state)
            switch state {
            case .success:
                self.isPermissionPresented = false
            case let .permissionRequested(info, manifest):
                ()
//                permissionRequest = MiniAppPermissionRequest(info: info, manifest: manifest)
//                isPermissionPresented = true
            default:
                ()
            }
        }
    }

    func load() {
        DispatchQueue.main.async {
            store.checkPermissions(
                miniAppId: miniAppId,
                miniAppVersion: miniAppVersion ?? ""
            )
        }
    }
    
    func openPermissionSettings() {
        guard
            let manifest = store.getCachedManifest(miniAppId: miniAppId)
        else {
            return
        }
        store.getInfo(miniAppId: miniAppId, miniAppVersion: miniAppVersion ?? "") { result in
            switch result {
            case .success(let info):
                permissionRequest = MiniAppPermissionRequest(info: info, manifest: manifest)
                isPermissionPresented = true
            case .failure(let error):
                store.viewState = .error(error)
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
