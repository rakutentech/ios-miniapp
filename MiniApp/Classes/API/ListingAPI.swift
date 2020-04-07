internal class ListingApi {
    let environment: Environment
    var path: String {
        return "host/\(environment.appId)/miniapps"
    }

    init(environment: Environment) {
        self.environment = environment
    }

    func createURLRequest() -> URLRequest? {

        guard let url = getListingURL() else {
            return nil
        }
        return URLRequest.createURLRequest(url: url, environment: environment)
    }

    func createURLRequest(for miniAppID: String) -> URLRequest? {

        guard let url = getListingURL(for: miniAppID) else {
            return nil
        }
        return URLRequest.createURLRequest(url: url, environment: environment)
    }

    private func getListingURL() -> URL? {
        guard let baseURL = environment.baseUrl else {
            return nil
        }
        return baseURL.appendingPathComponent(path)
    }

    private func getListingURL(for miniAppId: String) -> URL? {
        guard let baseURL = environment.baseUrl else {
            return nil
        }

        guard var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            return nil
        }

        components.queryItems = [URLQueryItem(name: "miniAppId", value: miniAppId)]

        return components.url
    }
}
