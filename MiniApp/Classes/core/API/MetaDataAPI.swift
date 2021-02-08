internal class MetaDataAPI {
    let environment: Environment

    init(environment: Environment) {
        self.environment = environment
    }

    func createURLRequest(appId: String, versionId: String) -> URLRequest? {
        guard let url = getMetaDataRequestURL(with: appId, versionId: versionId) else {
            return nil
        }
        return URLRequest.createURLRequest(url: url, environment: environment)
    }

    private func getMetaDataRequestURL(with miniAppId: String, versionId: String) -> URL? {
        guard let baseURL = environment.baseUrl else {
            return nil
        }
        let url =  baseURL.appendingPathComponent("host/\(environment.projectId)/miniapp/\(miniAppId)/version/\(versionId)")
        return url.appendingPathComponent("metadata")
    }
}
