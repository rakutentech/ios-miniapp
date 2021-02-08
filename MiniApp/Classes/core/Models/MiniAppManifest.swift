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

public struct MiniAppManifest: Codable {

    public var requiredPermissions: [MASDKCustomPermissionModel]?
    public var optionalPermissions: [MASDKCustomPermissionModel]?
    public var exampleHostAppMetaData: [String: String]?

    private enum CodingKeys: String, CodingKey {
        case requiredPermissions,
             optionalPermissions,
             exampleHostAppMetaData
    }
}
