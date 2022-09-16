import SwiftUI
import MiniApp

struct MiniAppSingleView: View {

    @Environment(\.dismiss) var dismiss

    @StateObject var viewModel: MiniAppWithTermsViewModel
    @StateObject var handler = MiniAppSUIViewHandler()

    var listType: MiniAppSettingsView.ListConfig
    var config: MiniAppSdkConfig {
        MiniAppSettingsView.SettingsConfig().sdkConfig(list: listType)
    }

    @State var miniAppId: String
    @State var miniAppVersion: String?
    @State var miniAppType: MiniAppType

    @State private var permissionRequest: MiniAppPermissionRequest?
    @State private var isPermissionPresented: Bool = false
    @State private var didAcceptTerms: Bool = false
    @State private var didAcceptSettingsTerms: Bool = false
    @State private var isSharePreviewPresented: Bool = false
    @State private var closeAlertMessage: MiniAppAlertMessage?

    init(listType: MiniAppSettingsView.ListConfig, miniAppId: String, miniAppVersion: String?, miniAppType: MiniAppType) {
        self.listType = listType
        let sdkConfig = MiniAppSettingsView.SettingsConfig().sdkConfig(list: listType)
        _viewModel = StateObject(wrappedValue:
            MiniAppWithTermsViewModel(miniAppId: miniAppId, miniAppVersion: miniAppVersion, miniAppType: .miniapp, sdkConfig: sdkConfig)
        )
        _miniAppId = State(wrappedValue: miniAppId)
        _miniAppVersion = State(wrappedValue: miniAppVersion)
        _miniAppType = State(wrappedValue: miniAppType)
    }

    var body: some View {
        VStack {
            MiniAppWithTermsView(viewModel: viewModel, handler: handler)
        }
        .navigationTitle(handler.isActive ? handler.miniAppTitle?() ?? "MiniApp" : "MiniApp")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar(content: {

            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    if let closeInfo = handler.closeAlertInfo?(), closeInfo.shouldDisplay ?? true {
                        closeAlertMessage = MiniAppAlertMessage(
                            title: closeInfo.title ?? "",
                            message: closeInfo.description ?? ""
                        )
                    } else {
                        dismiss.callAsFunction()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color(.secondarySystemBackground))
                            .frame(width: 30, height: 30, alignment: .center)
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Circle())
                }
                .alert(item: $closeAlertMessage) { errorMessage in
                    Alert(
                        title: Text(errorMessage.title),
                        message: Text(errorMessage.message),
                        dismissButton: .default(Text("Ok"), action: {
                            dismiss.callAsFunction()
                        })
                    )
                }
            }

            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    handler.action = .goBack
                } label: {
                    Image(systemName: "chevron.backward")
                }
                .disabled(!(viewModel.viewState == .success) || !viewModel.canGoBack)
            }

            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    handler.action = .goForward
                } label: {
                    Image(systemName: "chevron.forward")
                }
                .disabled(!(viewModel.viewState == .success) || !viewModel.canGoForward)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isSharePreviewPresented = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .sheet(isPresented: $isSharePreviewPresented, content: {
                    NavigationView {
                        MiniAppSharePreviewView(viewModel: viewModel)
                    }
                })
                .disabled(!(viewModel.viewState == .success))
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    openPermissionSettings()
                } label: {
                    Image(systemName: "gearshape")
                }
                .disabled(!(viewModel.viewState == .success))
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
            case .failure(let error):
                viewModel.viewState = .error(error)
            }
        }
    }
}

struct MiniAppSingleView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppSingleView(
            listType: .listI,
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
