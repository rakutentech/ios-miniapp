/// Mini App Manifest information
internal struct ManifestResponse: Decodable {
    var manifest: [String]
    
    private enum CodingKeys : String, CodingKey {
        case manifest = "manifest"
    }
}
