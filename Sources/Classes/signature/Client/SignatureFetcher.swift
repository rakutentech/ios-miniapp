internal class SignatureFetcher {

    struct Config {
        let baseURL: URL
        let subscriptionKey: String
    }

    let apiClient: SignatureAPI
    let config: Config

    init(apiClient: SignatureAPI, config: Config) {
        self.apiClient = apiClient
        self.config = config
    }

    // MARK: Fetch Key
    func fetchKey(with keyId: String, completionHandler: @escaping (Result<KeyModel, Error>) -> Void) {
        let url = config.baseURL.appendingPathComponent("keys").appendingPathComponent(keyId)
        let keyRequest = URLRequest.createURLRequest(url: url, subscriptionKey: config.subscriptionKey)

        apiClient.send(request: keyRequest) { (result) in
            switch result {
            case .success(let response):
                completionHandler(.success(response))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
}
