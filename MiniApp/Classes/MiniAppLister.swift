internal class MiniAppLister {
    var environment: Environment
    var miniAppClient: MiniAppClient

    init(environment: Environment) {
        self.environment = environment
        self.miniAppClient = MiniAppClient()
    }

    func fetchList(completionHandler: @escaping (Result<[MiniAppInfo], Error>) -> Void) {
        guard let url = environment.listingUrl else {
            return completionHandler(.failure(self.invalidURLError()))
        }

        self.miniAppClient.requestFromServer(request: listingURLRequest(url: url)) { (result) in
            switch result {
            case .success(let responseData):
                guard let decodeResponse = self.decodeListingResponse(with: responseData.data) else {
                    return completionHandler(.failure(self.invalidResponseData()))
                }
                return completionHandler(.success(decodeResponse))
            case .failure(let error):
                return completionHandler(.failure(error))
            }
        }
    }

    func listingURLRequest(url: URL) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.setAuthorizationHeader(environment: environment)
        return urlRequest
    }

    func decodeListingResponse(with dataResponse: Data?) -> [MiniAppInfo]? {
        do {
            return try JSONDecoder().decode(Array<MiniAppInfo>.self, from: dataResponse!) as [MiniAppInfo]
        } catch let error {
            print("Decoding Failed with Error: ", error)
            return nil
        }
    }

    func invalidURLError() -> NSError {
        return NSError(domain: "URL Error",
                       code: 0,
                       userInfo: [NSLocalizedDescriptionKey: "Invalid listing URL"])
    }

    func invalidResponseData() -> NSError {
        return NSError(domain: "Server Error",
                       code: 0,
                       userInfo: [NSLocalizedDescriptionKey: "Invalid response received"])
    }
}
