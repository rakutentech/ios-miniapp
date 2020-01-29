internal class ManifestApi {
    let environment: Environment

    init(environment: Environment) {
        self.environment = environment
    }

    func createURLRequest(appId: String, versionId: String) -> URLRequest? {
        guard let url = getManifestRequestUrl(with: appId, versionId: versionId) else {
            return nil
        }
        return urlRequest(url: url)
    }

    private func getManifestRequestUrl(with miniAppId: String, versionId: String) -> URL? {
        guard let baseURL = environment.baseUrl else {
            return nil
        }
        return baseURL.appendingPathComponent("/miniapp/\(miniAppId)/version/\(versionId)/manifest")
    }

    private func urlRequest(url: URL) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.setAuthorizationHeader(environment: environment)
        return urlRequest
    }

}
