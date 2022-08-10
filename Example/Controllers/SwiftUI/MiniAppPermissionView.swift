import SwiftUI
import MiniApp

struct MiniAppPermissionView: View {

    @EnvironmentObject var store: MiniAppPermissionStore

    @Binding var request: MiniAppPermissionRequest?
    @Binding var isPresented: Bool
    
    var optionalPermissionCount: Int {
        request?.manifest.optionalPermissions?.count ?? 0
    }

    var body: some View {
        if let request = request {
            ZStack {
                VStack {
                    AsyncImage(url: request.info.icon, content: { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80, alignment: .center)
                    }, placeholder: {
                        Circle()
                            .frame(width: 80, height: 80, alignment: .center)
                    })
                    Text(request.info.displayName ?? "")
                    Text(request.info.version.versionTag)
                        .foregroundColor(Color(.secondaryLabel))
                    Form {
                        Section("Required (\(request.manifest.requiredPermissions?.count ?? 0))") {
                            ForEach((request.manifest.requiredPermissions ?? []), id: \.permissionName) { perm in
                                Text(perm.permissionName.title)
                                .padding(10)
                            }
                        }
                        if optionalPermissionCount > 0 {
                            Section("Optional (\(optionalPermissionCount))") {
                                ForEach((request.manifest.optionalPermissions ?? []), id: \.permissionName) { perm in
                                    Toggle(
                                        isOn: Binding<Bool>(get: { perm.isPermissionGranted == .allowed }, set: { isOn in perm.isPermissionGranted = isOn ? .allowed : .denied }),
                                        label: {
                                        Text(perm.permissionName.title)
                                    })
                                    .tint(.red)
                                    .padding(10)
                                }
                            }
                        }
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 120)
                
                VStack {
                    Spacer()
                    VStack {
                        Button {
                            store.updatePermissions(miniAppId: request.info.id, manifest: request.manifest)
                            isPresented = false
                            store.viewState = .success
                        } label: {
                            Text("Accept")
                                .font(.system(size: 15, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding(15)
                        }
                        .tint(.white)
                        .background(RoundedRectangle(cornerRadius: 10).fill(.red))

                        Button {
                            isPresented = false
                        } label: {
                            Text("Cancel")
                                .font(.system(size: 15, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding(15)
                        }
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.secondarySystemBackground)))
                    }
                    .padding(.horizontal, 20)
                }
            }
        } else {
            Text("lul")
        }
    }
}

//struct MiniAppPermissionView_Previews: PreviewProvider {
//    static var previews: some View {
//        MiniAppPermissionView(info: MiniAppInfo(
//            id: "", icon: URL(string: "")!,
//            version: Version(versionTag: "",
//            versionId: ""
//        )), manifest: MiniAppManifest(
//            requiredPermissions: [],
//            optionalPermissions: [],
//            customMetaData: [],
//            accessTokenPermissions: [],
//            versionId: "")
//        )
//    }
//}
