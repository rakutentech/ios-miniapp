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
    var customMetaData: [String: String]?
    var accessTokenPermissions: [MASDKAccessTokenPermission]?

    private enum CodingKeys: String, CodingKey {
        case reqPermissions,
             optPermissions,
             customMetaData,
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

public struct MASDKAccessTokenPermission: Codable, Equatable, Hashable {
    public var audience: String
    public var scopes: [String]

    private enum CodingKeys: String, CodingKey {
        case audience,
             scopes
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(audience)
    }

    public static func == (lhs: MASDKAccessTokenPermission, rhs: MASDKAccessTokenPermission) -> Bool {
        lhs.audience == rhs.audience && rhs.scopes.sorted() == lhs.scopes.sorted()
    }

    public func isPartOf(_ fullScopes: [MASDKAccessTokenPermission]) -> Bool {
        var ret = false
        if let fullAudience = fullScopes.first(where: { scope in scope.audience == audience}) {
            ret = Set(scopes).isSubset(of: Set(fullAudience.scopes))
        }
        return ret
    }
}

/// Mini-app meta data information
public struct MiniAppManifest: Codable, Equatable {

    /// List of required permissions for a mini-app
    public let requiredPermissions: [MASDKCustomPermissionModel]?
    /// List of optional permissions for a mini-app
    public let optionalPermissions: [MASDKCustomPermissionModel]?
    /// Key-value pair data that is received from the endpoint
    public let customMetaData: [String: String]?
    /// List of scopes and audiences the MiniApp can require
    public let accessTokenPermissions: [MASDKAccessTokenPermission]?

    private enum CodingKeys: String, CodingKey {
        case requiredPermissions,
             optionalPermissions,
             customMetaData,
             accessTokenPermissions
    }

    init(requiredPermissions: [MASDKCustomPermissionModel]?,
         optionalPermissions: [MASDKCustomPermissionModel]?,
         customMetaData: [String: String]?,
         accessTokenPermissions: [MASDKAccessTokenPermission]?) {
        self.requiredPermissions = requiredPermissions
        self.optionalPermissions = optionalPermissions
        self.customMetaData = customMetaData
        self.accessTokenPermissions = accessTokenPermissions
    }

    public static func == (lhs: MiniAppManifest, rhs: MiniAppManifest) -> Bool {
        lhs.requiredPermissions?.sorted() == rhs.requiredPermissions?.sorted() &&
            lhs.optionalPermissions?.sorted() == rhs.optionalPermissions?.sorted() &&
            lhs.customMetaData == rhs.customMetaData
    }
}

internal struct CachedMetaData: Codable {
    let version: String
    let miniAppManifest: MiniAppManifest?

    init(version: String, miniAppManifest: MiniAppManifest) {
        self.version = version
        self.miniAppManifest = miniAppManifest
    }
}
