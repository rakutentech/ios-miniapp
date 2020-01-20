/// Mini App information
public struct MiniAppInfo: Decodable {
    var id: String
    var name: String
    var description: String
    var icon: URL
    var version: Version
}

struct Version: Decodable {
    var versionTag: String
    var versionId: String
}
