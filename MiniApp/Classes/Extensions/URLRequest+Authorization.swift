extension URLRequest {
    mutating func setAuthorizationHeader(environment: Environment) {
        if !environment.subscriptionKey.isEmpty {
            setValue(environment.subscriptionKey, forHTTPHeaderField: "Authorization")
        }
    }
}
