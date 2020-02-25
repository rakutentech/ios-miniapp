internal class ListingApi {
    let environment: Environment

    init(environment: Environment) {
        self.environment = environment
    }

    func createURLRequest(miniAppID: String? = nil) -> URLRequest? {
        guard let url = getListingURL(miniAppID) else {
            return nil
        }
        return URLRequest.createURLRequest(url: url, environment: environment)
    }

    private func getListingURL(_ miniAppId: String? = nil) -> URL? {
        guard let baseURL = environment.baseUrl else {
            return nil
        }

        guard var components = URLComponents(url: baseURL.appendingPathComponent("/oneapp/ios/\(environment.appVersion)/miniapps"), resolvingAgainstBaseURL: false) else {
            return nil
        }

        if let appId = miniAppId {
            components.queryItems = [URLQueryItem(name: "miniAppId", value: appId)]
        }

        return components.url
    }
}
