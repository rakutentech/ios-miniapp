/// Mini App information
public struct MiniAppInfo: Decodable {
    internal var id: String
    public var displayName: String
    public var icon: URL
    internal var version: Version

    private enum CodingKeys: String, CodingKey {
        case id,
        displayName,
        icon,
        version
    }
}

public struct Version: Decodable {
    public var versionTag: String
    public var versionId: String

    private enum CodingKeys: String, CodingKey {
        case versionTag,
        versionId
    }
}
