/// Mini App Meta data information
internal struct MetaDataResponse: Decodable {
    var bundleManifest: MetaDataCustomPermissionModel

    private enum CodingKeys: String, CodingKey {
        case bundleManifest
    }
}

/// Mini App Meta data information
internal struct MetaDataCustomPermissionModel: Decodable {
    var reqPermissions: [MACustomPermissionsResponse]?
    var optPermissions: [MACustomPermissionsResponse]?

    var exampleHostAppMetaData: [String: String]?

    private enum CodingKeys: String, CodingKey {
        case reqPermissions,
             optPermissions,
             exampleHostAppMetaData
    }
}

internal struct MACustomPermissionsResponse: Decodable {
    var name: String?
    var reason: String?

    private enum CodingKeys: String, CodingKey {
        case name,
             reason
    }
}

/// Mini-app meta data information
public struct MiniAppManifest: Codable {

    /// List of required permissions for a mini-app
    public let requiredPermissions: [MASDKCustomPermissionModel]?
    /// List of optional permissions for a mini-app
    public let optionalPermissions: [MASDKCustomPermissionModel]?
    /// Key-value pair data that is received from the endpoint
    public let exampleHostAppMetaData: [String: String]?

    private enum CodingKeys: String, CodingKey {
        case requiredPermissions,
             optionalPermissions,
             exampleHostAppMetaData
    }

    init(requiredPermissions: [MASDKCustomPermissionModel]?,
         optionalPermissions: [MASDKCustomPermissionModel]?,
         exampleHostAppMetaData: [String: String]?) {
        self.requiredPermissions = requiredPermissions
        self.optionalPermissions = optionalPermissions
        self.exampleHostAppMetaData = exampleHostAppMetaData
    }
}
