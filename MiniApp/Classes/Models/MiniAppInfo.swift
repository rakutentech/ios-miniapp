/// Mini App information
public struct MiniAppInfo: Decodable {
    internal var id: String
    public var displayName: String
    public var icon: URL
    internal var version: Version
}

public struct Version: Decodable {
    public var versionTag: String
    public var versionId: String
}
