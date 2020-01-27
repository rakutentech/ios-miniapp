internal class ListingApi {
    let environment: Environment

    init(environment: Environment) {
        self.environment = environment
    }

    func createURLRequest() -> URLRequest? {
        guard let url = getListingURL() else {
            return nil
        }
        return urlRequest(url: url)
    }

    private func getListingURL() -> URL? {
        guard let baseURL = environment.baseUrl else {
            return nil
        }
        return baseURL.appendingPathComponent("/oneapp/ios/\(environment.appVersion)/miniapps")
    }

    private func urlRequest(url: URL) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.setAuthorizationHeader(environment: environment)
        return urlRequest
    }
}
