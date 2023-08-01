import SwiftUI
import MiniApp

struct MiniAppFromBundle: View {

    @State var isMiniAppLoading: Bool = false

    init() {
        MiniApp.shared(with: ListConfiguration(listType: .listI).sdkConfig).setCustomPermissions(forMiniApp: "mini-app-testing-appid", permissionList: permissionList())
    }
    var body: some View {
        VStack {
            MiniAppSUIView(params: miniAppViewParams(config: ListConfiguration(listType: .listI).sdkConfig),
                           fromCache: true,
                           handler: MiniAppSUIViewHandler(),
                           fromBundle: true,
                           miniAppManifest: getMiniAppManifest())
        }
        .navigationTitle("MiniApp")
    }

    func miniAppViewParams(config: MiniAppSdkConfig) -> MiniAppViewParameters.DefaultParams {
        return MiniAppViewParameters.DefaultParams.init(
            config: MiniAppConfig(
                config: config,
                adsDisplayer: AdMobDisplayer(),
                messageDelegate: MiniAppViewMessageDelegator(),
                navigationDelegate: MiniAppViewNavigationDelegator()
            ),
            type: .miniapp,
            appId: "mini-app-testing-appid",
            version: "mini-app-testing-versionid",
            queryParams: getQueryParam()
        )
    }
    
    func getMiniAppManifest() -> MiniAppManifest? {
        return MiniAppManifest(requiredPermissions: permissionList(),
                               optionalPermissions: nil,
                               customMetaData: nil,
                               accessTokenPermissions: [MASDKAccessTokenScopes(audience: "rae",
                                                                               scopes: ["idinfo_read_openid", "memberinfo_read_point"])!],
                               versionId: "")
    }

    private func permissionList() -> [MASDKCustomPermissionModel] {
        do {
            let permissions: [MiniAppCustomPermissionType] = [.userName, .profilePhoto, .contactsList, .fileDownload, .accessToken, .deviceLocation, .sendMessage, .points]

            return try permissions.map { try MASDKCustomPermissionModel.customPermissionModel(permissionName: $0) }
        } catch {
            print("Failed to set up MiniApp permissions")
            return []
        }
    }
    
    func hardCodePermissions() {
        
    }
}

extension MASDKCustomPermissionModel {
    static func customPermissionModel(permissionName: MiniAppCustomPermissionType, isPermissionGranted: MiniAppCustomPermissionGrantedStatus = .allowed, permissionRequestDescription: String? = "") throws -> Self {
        let data = [
            "permissionName": permissionName.rawValue,
            "isPermissionGranted": isPermissionGranted.rawValue,
            "permissionDescription": permissionRequestDescription
        ]

        let encodedData = try JSONEncoder().encode(data)

        return try JSONDecoder().decode(Self.self, from: encodedData)
    }
}
