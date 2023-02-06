import SwiftUI
import MiniApp

@MainActor
class MiniAppTermsViewModel: ObservableObject {
    let sdkConfig: MiniAppSdkConfig
    let service: MiniAppPermissionService

    @Published var info: MiniAppInfo
    @Published var manifest: MiniAppManifest
    @Published var requiredPermissions: [MASDKCustomPermissionModel]
    @Published var optionalPermissions: [MASDKCustomPermissionModel]

    init(sdkConfig: MiniAppSdkConfig, info: MiniAppInfo, manifest: MiniAppManifest) {
        self.sdkConfig = sdkConfig
        self.service = MiniAppPermissionService(config: sdkConfig)
        self.info = info
        self.manifest = manifest
        self.requiredPermissions = manifest.requiredPermissions ?? []
        let optionalPermissions = service.updatePermissionsWithCache(miniAppId: info.id, permissions: manifest.optionalPermissions ?? [])
        self.optionalPermissions = optionalPermissions
    }

    func updatePermissions() {
        service.updatePermissions(miniAppId: info.id, permissionList: requiredPermissions + optionalPermissions)
    }

    var totalPermissionCount: Int {
        requiredPermissionCount + optionalPermissionCount
    }

    var requiredPermissionCount: Int {
        requiredPermissions.count
    }

    var optionalPermissionCount: Int {
        optionalPermissions.count
    }

    var accessTokenPermissionString: String? {
        manifest.accessTokenPermissions?.filter({ $0.audience == "rae" }).first?.scopes.joined(separator: ", ")
    }
}

struct MiniAppTermsView: View {

    @Environment(\.colorScheme) var colorScheme

    @StateObject var viewModel: MiniAppTermsViewModel

    @Binding var didAccept: Bool
    @State var didCancel: Bool = false

    init(didAccept: Binding<Bool>, request: MiniAppPermissionRequest) {
        _didAccept = didAccept
        _viewModel = StateObject(wrappedValue: MiniAppTermsViewModel(sdkConfig: request.sdkConfig, info: request.info, manifest: request.manifest)
        )
    }

    var body: some View {
        ZStack {
            VStack {
                VStack {
                    if #available(iOS 15.0, *) {
                        AsyncImage(url: viewModel.info.icon, content: { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60, alignment: .center)
                        }, placeholder: {
                            Rectangle()
                                .fill(Color(.secondarySystemBackground))
                                .frame(width: 60, height: 60, alignment: .center)
                        })
                    } else {
                        RemoteImageView(urlString: viewModel.info.icon.absoluteString)
                            .frame(width: 60, height: 60, alignment: .center)
                    }

                    VStack(spacing: 4) {
                        Text(viewModel.info.displayName ?? "")
                        Text(viewModel.info.version.versionTag)
                            .font(.system(size: 12))
                            .foregroundColor(Color(.secondaryLabel))
                    }
                }

                List {
                    Section(header: Text("Permissions (\(viewModel.totalPermissionCount))")) {
                        ForEach((viewModel.requiredPermissions), id: \.permissionName) { perm in
                            MiniAppTermsRequiredCell(pageName: pageName, name: perm.permissionName.title, description: perm.permissionDescription)
                        }
                        if viewModel.optionalPermissionCount > 0 {
                            ForEach((viewModel.optionalPermissions), id: \.permissionName) { perm in
                                MiniAppTermsOptionalCell(
                                    pageName: pageName,
                                    name: perm.permissionName.title,
                                    description: perm.permissionDescription,
                                    isAccepted: Binding<Bool>(
                                        get: { perm.isPermissionGranted == .allowed },
                                        set: { isOn in perm.isPermissionGranted = isOn ? .allowed : .denied }
                                    )
                                )
                            }
                        }
                    }

                    if let permissionString = viewModel.accessTokenPermissionString {
                        Section(header: Text("Access Tokens")) {
                            Text(permissionString)
                            .font(.system(size: 12))
                            .foregroundColor(Color(.secondaryLabel))
                        }
                    }
                    if viewModel.manifest.customMetaData != nil {
                        Section(header: Text("Metadata")) {
                            Text(viewModel.manifest.customMetaData.JSONString)
                            .font(.system(size: 12))
                            .foregroundColor(Color(.secondaryLabel))
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .padding(.top, 20)
            .padding(.bottom, 80)

            VStack {
                Spacer()
                VStack {
                    Button {
                        trackButtonTap(pageName: pageName, buttonTitle: "Accept")
                        viewModel.updatePermissions()
                        didAccept = true
                        // store.viewState = .success
                    } label: {
                        Text("Accept")
                            .font(.system(size: 15, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(15)
                    }
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 10).fill(.red))
                    .accessibilityIdentifier(AccessibilityIdentifiers.miniappPermissionAccept.identifier)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .background(
            Color(colorScheme == .light ? .secondarySystemBackground : .systemBackground)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
        )
        .trackPage(pageName: pageName)
    }
}

extension MiniAppTermsView: ViewTrackable {
	var pageName: String {
		return NSLocalizedString("demo.app.rat.page.name.terms", comment: "")
	}
}

struct MiniAppTermsView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppTermsView(
            didAccept: .constant(false),
            request: MiniAppPermissionRequest(
                sdkConfig: Config.sampleSdkConfig(),
                info:
                MiniAppInfo(
                    id: "",
                    icon: URL(string: "")!,
                    version: Version(versionTag: "", versionId: "")
                ), manifest: MiniAppManifest(
                    requiredPermissions: [],
                    optionalPermissions: [],
                    customMetaData: [:],
                    accessTokenPermissions: [],
                    versionId: ""
                )
            )
        )
    }
}
