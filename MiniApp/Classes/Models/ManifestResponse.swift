/**
 * Model of the response from 'GET /app:/version:/manifest' endpoint.
 */
struct ManifestResponse: Decodable {
    let manifest: [String]
}
