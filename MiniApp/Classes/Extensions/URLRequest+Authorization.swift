extension URLRequest {
    mutating func setAuthorizationHeader(environment: Environment) {
        if environment.subscriptionKey.count > 0 {
            setValue(environment.subscriptionKey, forHTTPHeaderField: "Authorization")
        }
    }
}
