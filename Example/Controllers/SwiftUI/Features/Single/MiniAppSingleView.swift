import SwiftUI
import MiniApp

struct MiniAppSingleView: View {

    @Environment(\.presentationMode) var presentationMode

    @StateObject var viewModel: MiniAppWithTermsViewModel
    @StateObject var handler = MiniAppSUIViewHandler()

    var listType: ListType

    @State var miniAppId: String
    @State var miniAppVersion: String?
    @State var miniAppType: MiniAppType

    @State private var permissionRequest: MiniAppPermissionRequest?
    @State private var isPermissionPresented: Bool = false
    @State private var didAcceptTerms: Bool = false
    @State private var didAcceptSettingsTerms: Bool = false
    @State private var isSharePreviewPresented: Bool = false
    @State private var closeAlertMessage: MiniAppAlertMessage?
    @State private var permissionToolbarEnabled: Bool = false

    init(listType: ListType, miniAppId: String, miniAppVersion: String?, miniAppType: MiniAppType) {
        self.listType = listType
        _viewModel = StateObject(wrappedValue:
            MiniAppWithTermsViewModel(
                miniAppId: miniAppId,
                miniAppVersion: miniAppVersion,
                miniAppType: .miniapp,
                listType: listType
            )
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
                CloseButton {
                    trackButtonTap(pageName: pageName, buttonTitle: "Close")
                    if let closeInfo = handler.closeAlertInfo?(), closeInfo.shouldDisplay ?? true {
                        closeAlertMessage = MiniAppAlertMessage(
                            title: closeInfo.title ?? "",
                            message: closeInfo.description ?? ""
                        )
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .alert(item: $closeAlertMessage) { errorMessage in
                    Alert(
                        title: Text(errorMessage.title),
                        message: Text(errorMessage.message),
                        primaryButton: .default(Text("Ok"), action: {
                            presentationMode.wrappedValue.dismiss()
                        }),
                        secondaryButton: .cancel(Text("Cancel"))
                    )
                }
            }

            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    trackButtonTap(pageName: pageName, buttonTitle: "Back")
                    handler.action = .goBack
                } label: {
                    Image(systemName: "chevron.backward")
                }
                .disabled(!(viewModel.viewState == .success) || !viewModel.canGoBack)
            }

            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    trackButtonTap(pageName: pageName, buttonTitle: "Forward")
                    handler.action = .goForward
                } label: {
                    Image(systemName: "chevron.forward")
                }
                .disabled(!(viewModel.viewState == .success) || !viewModel.canGoForward)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    trackButtonTap(pageName: pageName, buttonTitle: "Share")
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
                    trackButtonTap(pageName: pageName, buttonTitle: "Permissions")
                    openPermissionSettings()
                } label: {
                    Image(systemName: "gearshape")
                }
                .disabled(!(viewModel.isSuccessOrOffline))
            }

        })
        .sheet(item: $permissionRequest, content: { request in
            NavigationView {
                MiniAppTermsView(didAccept: $didAcceptSettingsTerms, request: request)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            trackButtonTap(pageName: "Permissions", buttonTitle: "Cancel")
                            permissionRequest = nil
                        } label: {
                            Text("Cancel")
                        }
                    }
                }
                .trackPage(pageName: "Permissions")
            }
        })
        .onChange(of: didAcceptSettingsTerms, perform: { accepted in
            if accepted {
                didAcceptSettingsTerms = false
                permissionRequest = nil
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
        .onChange(of: permissionRequest, perform: { request in
            if let request = request {
                sendPauseMiniApp(miniAppId: request.info.id, version: request.info.version.versionId)
            } else {
                sendResumeMiniApp(miniAppId: viewModel.miniAppId, version: viewModel.miniAppVersion)
            }
        })
        .onChange(of: isSharePreviewPresented, perform: { isPresented in
            if isPresented {
                sendPauseMiniApp(miniAppId: viewModel.miniAppId, version: viewModel.miniAppVersion)
            } else {
                sendResumeMiniApp(miniAppId: viewModel.miniAppId, version: viewModel.miniAppVersion)
            }
        })
        .trackPage(pageName: pageName)
    }

    func openPermissionSettings() {
        viewModel.fetchPermissionRequest { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let request):
                    permissionRequest = request
                case .failure(let error):
                    viewModel.viewState = .error(error)
                }
            }
        }
    }
}

extension MiniAppSingleView: ViewTrackable {
    var pageName: String {
        return handler.miniAppTitle?() ?? "MiniAppSingleView"
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

struct MiniAppPermissionRequest: Identifiable, Equatable {
    let id = UUID()
    let sdkConfig: MiniAppSdkConfig
    let info: MiniAppInfo
    let manifest: MiniAppManifest

    static func == (lhs: MiniAppPermissionRequest, rhs: MiniAppPermissionRequest) -> Bool {
        return lhs.id == rhs.id
    }
}
