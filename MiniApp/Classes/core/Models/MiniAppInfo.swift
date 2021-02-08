/// Model for a Mini App information
public struct MiniAppInfo: Codable {
    public static func == (lhs: MiniAppInfo, rhs: MiniAppInfo) -> Bool {
        return lhs.id == rhs.id
    }

    /// Unique identifier of a Miniapp
    public var id: String
    /// Name given for a Miniapp that will be displayed on the list
    public var displayName: String?
    /// App Icon associated for the Miniapp
    public var icon: URL
    /// Version information of a Miniapp
    public var version: Version
    /// Latest Meta-data information of a Miniapp
    public var manifest: MiniAppManifest?
    /// Pervious version of meta-data information of a Miniapp
    public var previousManifest: MiniAppManifest?

    private enum CodingKeys: String, CodingKey {
        case id,
        displayName,
        icon,
        version,
        manifest,
        previousManifest
    }
}

/// Miniapp version information
public struct Version: Codable, Hashable {
    /// Custom Tag name associated for every Miniapp which was given while uploading it in the platform
    public var versionTag: String
    /// Version number associated for every Miniapp which was given while uploading it in the platform
    public var versionId: String

    private enum CodingKeys: String, CodingKey {
        case versionTag,
        versionId
    }
}
