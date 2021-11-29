internal class MetaDataAPI {
    let environment: Environment

    init(with environment: Environment) {
        self.environment = environment
    }

    func createURLRequest(appId: String, versionId: String, testPath: String? = nil, languageCode: String) -> URLRequest? {
        guard let url = getMetaDataRequestURL(with: appId,
                                              versionId: versionId,
                                              testPath: testPath,
                                              languageCode: languageCode) else {
            return nil
        }
        return URLRequest.createURLRequest(url: url, environment: environment)
    }

    private func getMetaDataRequestURL(with miniAppId: String, versionId: String, testPath: String? = nil, languageCode: String) -> URL? {
        guard let baseURL = environment.baseUrl else {
            return nil
        }
        var url =  baseURL.appendingPathComponent("host/\(environment.projectId)/miniapp/\(miniAppId)/version/\(versionId)")
        if let test = testPath {
            url = url.appendingPathComponent(test)
        }
        return url.appendingPathComponent("metadata").appendingQueryItem("lang", value: languageCode)
    }
}

extension URL {
    func appendingQueryItem(_ key: String, value: String?) -> URL {
        guard var urlComponents = URLComponents(string: absoluteString) else { return absoluteURL }
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []
        let queryItem = URLQueryItem(name: key, value: value)
        queryItems.append(queryItem)
        urlComponents.queryItems = queryItems
        return urlComponents.url!
    }
}
