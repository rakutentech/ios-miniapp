internal class ListingApi {
    let environment: Environment

    init(environment: Environment) {
        self.environment = environment
    }

    func createURLRequest() -> URLRequest? {
        guard let url = getListingURL() else {
            return nil
        }
        return URLRequest.createURLRequest(url: url, environment: environment)
    }

    private func getListingURL() -> URL? {
        guard let baseURL = environment.baseUrl else {
            return nil
        }
        return baseURL.appendingPathComponent("/oneapp/ios/\(environment.appVersion)/miniapps")
    }
}
