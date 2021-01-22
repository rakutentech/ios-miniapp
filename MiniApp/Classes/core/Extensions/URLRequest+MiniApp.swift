extension URLRequest {
    static func createURLRequest(url: URL, environment: Environment) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        if !environment.subscriptionKey.isEmpty {
            urlRequest.setValue("ras-" + environment.subscriptionKey, forHTTPHeaderField: "apiKey")
        }
        return urlRequest
    }
}
