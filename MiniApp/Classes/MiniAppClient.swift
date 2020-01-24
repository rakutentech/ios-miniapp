fileprivate extension NSError {

    class func serverError(code: Int, message: String) -> NSError {
        return NSError(domain: "APIClient", code: code, userInfo: [NSLocalizedDescriptionKey: message])
    }

    class func unknownServerError(httpResponse: HTTPURLResponse?) -> NSError {
        let unknownError = NSError.serverError(code: (httpResponse)?.statusCode ?? 0, message: "Unknown server error occurred")
        return unknownError
    }

    class func invalidURLError() -> NSError {
        return NSError(domain: "API Client", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL error"])
    }
}

protocol SessionProtocol {
    func startDataTask(with request: URLRequest, completionHandler: @escaping (Result<ResponseData, Error>) -> Void)
}

class MiniAppClient {
    let session: SessionProtocol
    let listingApi: ListingApi
    let environment: Environment

    init(session: SessionProtocol = URLSession(configuration: URLSessionConfiguration.default)) {
        self.session = session
        self.environment = Environment()
        self.listingApi = ListingApi(environment: self.environment)
    }

    func getMiniAppsList(completionHandler: @escaping (Result<ResponseData, Error>) -> Void) {

        guard let urlRequest = self.listingApi.urlRequest() else {
            return completionHandler(.failure(NSError.invalidURLError()))
        }

        session.startDataTask(with: urlRequest) { (result) in
            switch result {
            case .success(let responseData):
                if !(200...299).contains(responseData.httpResponse.statusCode) {
                    do {
                        let errorModel = try JSONDecoder().decode(ErrorData.self, from: responseData.data)
                        return completionHandler(.failure(NSError.serverError(code: errorModel.code, message: errorModel.message)))
                    } catch {
                        return completionHandler(.failure(NSError.unknownServerError(httpResponse: responseData.httpResponse)))
                    }
                }
                return completionHandler(.success(ResponseData(responseData.data, responseData.httpResponse)))
            case .failure(let error):
                return completionHandler(.failure(error))
            }
        }
    }
}
