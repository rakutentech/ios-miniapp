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
    @State private var shouldPresentModalView: Bool = false

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
                    viewModel.removeHandlerFromList(handler)
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
                .accessibilityIdentifier(AccessibilityIdentifiers.miniappHeaderClose.identifier)
                .alert(item: $closeAlertMessage) { errorMessage in
                    Alert(
                        title: Text(errorMessage.title),
                        message: Text(errorMessage.message),
                        primaryButton: .default(Text("Ok"), action: {
                            presentationMode.wrappedValue.dismiss()
                        }),
                        secondaryButton: .cancel(Text("Cancel"), action: {
                            viewModel.shouldCloseMiniApp.send(false)
                        })
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
                .accessibilityIdentifier(AccessibilityIdentifiers.miniappHeaderBack.identifier)
            }

            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    trackButtonTap(pageName: pageName, buttonTitle: "Forward")
                    handler.action = .goForward
                } label: {
                    Image(systemName: "chevron.forward")
                }
                .disabled(!(viewModel.viewState == .success) || !viewModel.canGoForward)
                .accessibilityIdentifier(AccessibilityIdentifiers.miniappHeaderForward.identifier)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    trackButtonTap(pageName: pageName, buttonTitle: "Share")
                    isSharePreviewPresented = true
                    shouldPresentModalView = true
                    permissionRequest = nil
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .disabled(!(viewModel.viewState == .success))
                .accessibilityIdentifier(AccessibilityIdentifiers.miniappHeaderShare.identifier)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    trackButtonTap(pageName: pageName, buttonTitle: "Permissions")
                    shouldPresentModalView = true
                    isSharePreviewPresented = false
                    openPermissionSettings()
                } label: {
                    Image(systemName: "gearshape")
                }
                .disabled(!(viewModel.isSuccessOrOffline))
                .accessibilityIdentifier(AccessibilityIdentifiers.miniappHeaderSettings.identifier)
            }

        })
        .sheet(isPresented: $shouldPresentModalView, onDismiss: {shouldPresentModalView = false}, content: {
            NavigationView {
                if let permissionRequest = permissionRequest {
                    MiniAppTermsView(didAccept: $didAcceptSettingsTerms, request: permissionRequest)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                trackButtonTap(pageName: "Permissions", buttonTitle: "Cancel")
                                self.permissionRequest = nil
                                shouldPresentModalView = false
                            } label: {
                                Text("Cancel")
                            }
                            .accessibilityIdentifier(AccessibilityIdentifiers.miniappPermissionCancel.identifier)
                        }
                    }
                    .trackPage(pageName: "Permissions")
                }
                if isSharePreviewPresented {
                    MiniAppSharePreviewView(viewModel: viewModel)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            CloseButton {
                                trackButtonTap(pageName: NSLocalizedString("demo.app.rat.page.name.share.preview", comment: ""), buttonTitle: "Cancel")
                                isSharePreviewPresented = false
                                shouldPresentModalView = false
                            }
                            .accessibilityIdentifier(AccessibilityIdentifiers.miniappSharePreviewCancel.identifier)
                        }
                    }
                    .trackPage(pageName: NSLocalizedString("demo.app.rat.page.name.share.preview", comment: ""))
                }
            }
        })
        .onChange(of: didAcceptSettingsTerms, perform: { accepted in
            if accepted {
                didAcceptSettingsTerms = false
                permissionRequest = nil
                shouldPresentModalView = false
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
        .onChange(of: viewModel.shouldCloseMiniApp.value, perform: { newValue in
            if newValue {
                if viewModel.closeWithConfirmation {
                    if let closeInfo = handler.closeAlertInfo?(), closeInfo.shouldDisplay ?? true {
                        closeAlertMessage = MiniAppAlertMessage(
                            title: closeInfo.title ?? "",
                            message: closeInfo.description ?? ""
                        )
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
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
