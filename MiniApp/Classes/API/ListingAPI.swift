internal class ListingApi {
    let environment: Environment

    init(environment: Environment) {
        self.environment = environment
    }

    func createURLRequest(_ miniAppID: String? = nil) -> URLRequest? {
        guard let url = getListingURL(miniAppID) else {
            return nil
        }
        return URLRequest.createURLRequest(url: url, environment: environment)
    }

    private func getListingURL(_ miniAppId: String? = nil) -> URL? {
        guard let baseURL = environment.baseUrl else {
            return nil
        }

        var appIdParam = ""

        if let appId = miniAppId {
            appIdParam = "/\(appId)"
        }

        return baseURL.appendingPathComponent("/oneapp/ios/\(environment.appVersion)/miniapps\(appIdParam)")
    }
}
