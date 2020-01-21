/// Mini App information
public struct MiniAppInfo: Decodable {
    public var id: String
    public var name: String
    public var description: String
    public var icon: URL
    public var version: Version
}

public struct Version: Decodable {
    public var versionTag: String
    public var versionId: String
}
