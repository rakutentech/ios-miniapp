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
    var accessTokenPermissions: [MASDKAccessTokenScopes]?

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

/// Mini App access token permissions containing audience and scopes, usually taken from manifest.json
public struct MASDKAccessTokenScopes: Codable, Equatable, Hashable {
    public var audience: String
    public var scopes: [String]

    private enum CodingKeys: String, CodingKey {
        case audience,
             scopes
    }

    /// Modifies this instance of MASDKAccessTokenScopes with a new audience or scopes
    ///
    /// - Parameters:
    ///   - newAudience: optional. a new audience String. If nil is provided then it is ignored
    ///   - newScopes: optional. a new scope array. If nil is provided then it is ignored
    /// - Returns: self
    mutating func with(audience newAudience: String? = nil, scopes newScopes: [String]? = nil) -> MASDKAccessTokenScopes {
        if let aud = newAudience {
            audience = aud
        }
        if let sco = newScopes {
            scopes = sco
        }
        return  self
    }

    public init?(audience: String?, scopes: [String]?) {
        if let audience = audience, let scopes = scopes {
            self.audience = audience
            self.scopes = scopes
        } else {
            return nil
        }
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(audience)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.audience == rhs.audience && rhs.scopes.sorted() == lhs.scopes.sorted()
    }

    /// This method checks if this Access Token permission is contained in an array of permissions by checking audience and scopes.
    /// Scopes can be partially provided. Here is an example:
    ///
    ///    {
    ///        "audience": "rae",
    ///        "scopes": ["memberinfo_read_point"]
    ///    }
    ///
    /// is part of
    ///
    ///    {
    ///        "accessTokenPermissions": [
    ///          {
    ///            "audience": "rae",
    ///            "scopes": ["idinfo_read_openid", "memberinfo_read_point"]
    ///          },
    ///          {
    ///            "audience": "api-c",
    ///            "scopes": ["your_service_scope_here"]
    ///          }
    ///        ]
    ///    }
    ///
    /// - Parameter fullScopes: an array containing the Access Token permissions we want to compare this one
    /// - Returns: a boolean stating if this access token permission is contained in fullScopes array
    public func isPartOf(_ fullScopes: [Self]) -> Bool {
        var ret = false
        if let fullAudience = fullScopes.first(where: { scope in scope.audience == audience}) {
            ret = Set(scopes).isSubset(of: Set(fullAudience.scopes))
        }
        return ret
    }
}

/// Mini-app meta data information
public struct MiniAppManifest: Codable, Equatable, Hashable {

    /// List of required permissions for a mini-app
    public let requiredPermissions: [MASDKCustomPermissionModel]?
    /// List of optional permissions for a mini-app
    public let optionalPermissions: [MASDKCustomPermissionModel]?
    /// Key-value pair data that is received from the endpoint
    public let customMetaData: [String: String]?
    /// List of scopes and audiences the MiniApp can require
    public let accessTokenPermissions: [MASDKAccessTokenScopes]?
    /// VersionId of the Mini-App
    public let versionId: String?

    private enum CodingKeys: String, CodingKey {
        case requiredPermissions,
             optionalPermissions,
             customMetaData,
             accessTokenPermissions,
             versionId
    }

    init(requiredPermissions: [MASDKCustomPermissionModel]?,
         optionalPermissions: [MASDKCustomPermissionModel]?,
         customMetaData: [String: String]?,
         accessTokenPermissions: [MASDKAccessTokenScopes]?,
         versionId: String?) {
        self.requiredPermissions = requiredPermissions
        self.optionalPermissions = optionalPermissions
        self.customMetaData = customMetaData
        self.accessTokenPermissions = accessTokenPermissions
        self.versionId = versionId
    }

    public static func == (lhs: MiniAppManifest, rhs: MiniAppManifest) -> Bool {
        lhs.requiredPermissions?.sorted() == rhs.requiredPermissions?.sorted() &&
            lhs.optionalPermissions?.sorted() == rhs.optionalPermissions?.sorted() &&
            lhs.customMetaData == rhs.customMetaData
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(requiredPermissions)
        hasher.combine(optionalPermissions)
        hasher.combine(customMetaData)
        hasher.combine(accessTokenPermissions)
        hasher.combine(versionId)
    }
}

internal struct CachedMetaData: Codable, Equatable {
    let hash: Int
    let version: String
    let miniAppManifest: MiniAppManifest?

    init(version: String, miniAppManifest: MiniAppManifest, hash: Int) {
        self.version = version
        self.miniAppManifest = miniAppManifest
        self.hash = hash
    }

    static func ==(lhs: CachedMetaData, rhs: CachedMetaData) -> Bool {
        lhs.hash == rhs.hash
                && lhs.miniAppManifest.hashValue == rhs.miniAppManifest.hashValue
                && lhs.version == rhs.version
    }
}
