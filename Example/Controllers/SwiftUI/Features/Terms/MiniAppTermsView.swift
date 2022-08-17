import SwiftUI
import MiniApp

struct MiniAppTermsView: View {
    
    @StateObject var store = MiniAppPermissionStore()
    
    @Binding var didAccept: Bool
    @State var didCancel: Bool = false
    
    var request: MiniAppPermissionRequest
    
    var requiredPermissionCount: Int {
        request.manifest.requiredPermissions?.count ?? 0
    }
    
    var optionalPermissionCount: Int {
        request.manifest.optionalPermissions?.count ?? 0
    }

    var body: some View {
        ZStack {
            VStack {
                VStack {
                    AsyncImage(url: request.info.icon, content: { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60, alignment: .center)
                    }, placeholder: {
                        Rectangle()
                            .fill(Color(.secondarySystemBackground))
                            .frame(width: 60, height: 60, alignment: .center)
                    })
                    
                    VStack(spacing: 4) {
                        Text(request.info.displayName ?? "")
                        Text(request.info.version.versionTag)
                            .font(.system(size: 12))
                            .foregroundColor(Color(.secondaryLabel))
                    }
                }

                List {
                    Section("Permissions (\(requiredPermissionCount + optionalPermissionCount))") {
                        ForEach((request.manifest.requiredPermissions ?? []), id: \.permissionName) { perm in
                            MiniAppTermsRequiredCell(name: perm.permissionName.title, description: perm.permissionDescription)
                        }
                        if optionalPermissionCount > 0 {
                            ForEach((request.manifest.optionalPermissions ?? []), id: \.permissionName) { perm in
                                MiniAppTermsOptionalCell(
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
                    
                    if let permissionString = getAccessTokenPermissionString() {
                        Section("Access Tokens") {
                            Text(permissionString)
                            .font(.system(size: 12))
                            .foregroundColor(Color(.secondaryLabel))
                        }
                    }

                    Section("Metadata") {
                        Text(request.manifest.customMetaData.JSONString)
                        .font(.system(size: 12))
                        .foregroundColor(Color(.secondaryLabel))
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
                        store.updatePermissions(miniAppId: request.info.id, manifest: request.manifest)
                        didAccept = true
                        store.viewState = .success
                    } label: {
                        Text("Accept")
                            .font(.system(size: 15, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(15)
                    }
                    .tint(.white)
                    .background(RoundedRectangle(cornerRadius: 10).fill(.red))

//                    Button {
//                        didCancel = false
//                    } label: {
//                        Text("Cancel")
//                            .font(.system(size: 15, weight: .bold))
//                            .frame(maxWidth: .infinity)
//                            .padding(15)
//                    }
//                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(.secondarySystemBackground)))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
    
    func getAccessTokenPermissionString() -> String? {
        request.manifest.accessTokenPermissions?.filter({ $0.audience == "rae" }).first?.scopes.joined(separator: ", ")
    }
}

struct MiniAppTermsView_Previews: PreviewProvider {
    static var previews: some View {
        MiniAppTermsView(
            store: MiniAppPermissionStore(),
            didAccept: .constant(false),
            request: MiniAppPermissionRequest(info:
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
