import Foundation

internal class ListingApi {
    let environment: Environment
    var path: String {
        return "host/\(environment.projectId)/miniapps"
    }

    init(environment: Environment) {
        self.environment = environment
    }

    func createURLRequest(testPath: String? = nil) -> URLRequest? {
        guard let url = getListingURL(testPath: testPath) else {
            return nil
        }
        return URLRequest.createURLRequest(url: url, environment: environment)
    }

    func createURLRequest(for miniAppID: String, testPath: String? = nil) -> URLRequest? {
        guard let url = getListingURL(for: miniAppID, testPath: testPath) else {
            return nil
        }
        return URLRequest.createURLRequest(url: url, environment: environment)
    }

    private func getListingURL(testPath: String? = nil) -> URL? {
        guard let baseURL = environment.baseUrl else {
            return nil
        }
        var url = baseURL.appendingPathComponent(path)
        if let testPath = testPath {
            url = url.appendingPathComponent(testPath)
        }
        return url
    }

    private func getListingURL(for miniAppId: String, testPath: String? = nil) -> URL? {
        guard let baseURL = getListingURL(testPath: testPath) else {
            return nil
        }
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            return nil
        }

        components.queryItems = [URLQueryItem(name: "miniAppId", value: miniAppId)]

        return components.url
    }
}
