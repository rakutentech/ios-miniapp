extension URLRequest {
    static func createURLRequest(url: URL, environment: Environment) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        if environment.subscriptionKey.isEmpty {
            urlRequest.setValue(environment.subscriptionKey, forHTTPHeaderField: "Authorization")
        }
        return urlRequest
    }
}
