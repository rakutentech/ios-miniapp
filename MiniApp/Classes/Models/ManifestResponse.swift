/// Mini App Manifest information
internal struct ManifestResponse: Decodable {
    var id: String
    var versionTag: String
    var name: String
    var files: [String]
}
