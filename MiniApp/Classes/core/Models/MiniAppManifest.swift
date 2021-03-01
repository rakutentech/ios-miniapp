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
    var accessTokenPermissions: [AccessTokenPermission]?

    private enum CodingKeys: String, CodingKey {
        case reqPermissions,
             optPermissions,
             exampleHostAppMetaData,
             accessTokenPermissions
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

public struct AccessTokenPermission: Codable, Equatable, Hashable {
    var audience: String
    var scopes: [String]

    private enum CodingKeys: String, CodingKey {
        case audience,
             scopes
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(audience)
    }

    public static func == (lhs: AccessTokenPermission, rhs: AccessTokenPermission) -> Bool {
        lhs.audience == rhs.audience
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
    /// List of scopes and audiences the MiniApp can require
    public let accessTokenPermissions: [AccessTokenPermission]?

    private enum CodingKeys: String, CodingKey {
        case requiredPermissions,
             optionalPermissions,
             exampleHostAppMetaData,
             accessTokenPermissions
    }

    init(requiredPermissions: [MASDKCustomPermissionModel]?,
         optionalPermissions: [MASDKCustomPermissionModel]?,
         exampleHostAppMetaData: [String: String]?,
         accessTokenPermissions: [AccessTokenPermission]?) {
        self.requiredPermissions = requiredPermissions
        self.optionalPermissions = optionalPermissions
        self.exampleHostAppMetaData = exampleHostAppMetaData
        self.accessTokenPermissions = accessTokenPermissions
    }
}
