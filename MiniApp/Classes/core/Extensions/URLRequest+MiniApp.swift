extension URLRequest {
    static func createURLRequest(url: URL, subscriptionKey: String = "") -> URLRequest {
        var urlRequest = URLRequest(url: url)
        if !subscriptionKey.isEmpty {
            urlRequest.setSubscriptionKey(subscriptionKey)
        }
        return urlRequest
    }

    static func createURLRequest(url: URL, environment: Environment) -> URLRequest {
        createURLRequest(url: url, subscriptionKey: environment.subscriptionKey)
    }

    mutating func setSubscriptionKey(_ key: String) {
        var keyValue = key
        if !key.hasPrefix("ras-") {
            keyValue = "ras-\(key)"
        }
        setValue(keyValue, forHTTPHeaderField: "apiKey")
    }
}
