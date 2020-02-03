internal class ManifestApi {
    let environment: Environment

    init(environment: Environment) {
        self.environment = environment
    }

    func createURLRequest(appId: String, versionId: String) -> URLRequest? {
        guard let url = getManifestRequestUrl(with: appId, versionId: versionId) else {
            return nil
        }
        return URLRequest.createURLRequest(url: url, environment: environment)
    }

    private func getManifestRequestUrl(with miniAppId: String, versionId: String) -> URL? {
        guard let baseURL = environment.baseUrl else {
            return nil
        }
        return baseURL.appendingPathComponent("/miniapp/\(miniAppId)/version/\(versionId)/manifest")
    }
}
