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

    private enum CodingKeys: String, CodingKey {
        case reqPermissions,
             optPermissions,
             customMetaData
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
public struct MiniAppManifest: Codable, Equatable {

    /// List of required permissions for a mini-app
    public let requiredPermissions: [MASDKCustomPermissionModel]?
    /// List of optional permissions for a mini-app
    public let optionalPermissions: [MASDKCustomPermissionModel]?
    /// Key-value pair data that is received from the endpoint
    public let customMetaData: [String: String]?

    private enum CodingKeys: String, CodingKey {
        case requiredPermissions,
             optionalPermissions,
             customMetaData
    }

    init(requiredPermissions: [MASDKCustomPermissionModel]?,
         optionalPermissions: [MASDKCustomPermissionModel]?,
         customMetaData: [String: String]?) {
        self.requiredPermissions = requiredPermissions
        self.optionalPermissions = optionalPermissions
        self.customMetaData = customMetaData
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
