/// Mini App Meta data information
internal struct MetaDataResponse: Decodable {
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
    public var requiredPermissions: [MASDKCustomPermissionModel]?
    /// List of optional permissions for a mini-app
    public var optionalPermissions: [MASDKCustomPermissionModel]?
    /// Key-value pair data that is received from the endpoint
    public var exampleHostAppMetaData: [String: String]?

    private enum CodingKeys: String, CodingKey {
        case requiredPermissions,
             optionalPermissions,
             exampleHostAppMetaData
    }
}
