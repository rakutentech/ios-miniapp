/// Mini App Manifest information
internal struct ManifestResponse: Decodable {
    var manifest: [String]
    var publicKeyId: String?

    private enum CodingKeys: String, CodingKey {
        case manifest, publicKeyId
    }
}
