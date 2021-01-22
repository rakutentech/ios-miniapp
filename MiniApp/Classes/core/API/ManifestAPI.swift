internal class ManifestApi {
    let environment: Environment

    init(environment: Environment) {
        self.environment = environment
    }

    func createURLRequest(appId: String, versionId: String, testPath: String? = nil) -> URLRequest? {
        guard let url = getManifestRequestUrl(with: appId, versionId: versionId, testPath: testPath) else {
            return nil
        }
        return URLRequest.createURLRequest(url: url, environment: environment)
    }

    private func getManifestRequestUrl(with miniAppId: String, versionId: String, testPath: String? = nil) -> URL? {
        guard let baseURL = environment.baseUrl else {
            return nil
        }
        var url =  baseURL.appendingPathComponent("host/\(environment.projectId)/miniapp/\(miniAppId)/version/\(versionId)")
        if let test = testPath {
            url = url.appendingPathComponent(test)
        }
        return url.appendingPathComponent("manifest")
    }
}
