struct ResponseData {
    let data: Data
    let httpResponse: HTTPURLResponse
    init(_ data: Data, _ httpResponse: HTTPURLResponse) {
        self.data = data
        self.httpResponse = httpResponse
    }
}

struct ErrorData: Decodable, Equatable {
    let code: Int
    let message: String
}

fileprivate extension NSError {
    class func serverError(code: Int, message: String) -> NSError {
        return NSError(domain: "Server", code: code, userInfo: [NSLocalizedDescriptionKey: message])
    }
}

protocol MiniAppClientProtocol {
    func startDataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
}

extension URLSession: MiniAppClientProtocol {
    func startDataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        dataTask(with: request) { (data, response, error) in
            completionHandler(data, response, error)
        }.resume()
    }
}

class MiniAppClient {
    let session: MiniAppClientProtocol

    init(session: MiniAppClientProtocol = URLSession(configuration: URLSessionConfiguration.default)) {
        self.session = session
    }

    func requestFromServer(request: URLRequest, completionHandler: @escaping (Result<ResponseData, Error>) -> Void) {

        session.startDataTask(with: request) { (data, response, error) in
            if let err = error {
                return completionHandler(.failure(err))
            }

            guard let data = data else {
                let dataError = NSError.serverError(code: (response as? HTTPURLResponse)?.statusCode ?? 0, message: "Response is Nil")
                return completionHandler(.failure(dataError))
            }

            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    do {
                        let errorModel = try JSONDecoder().decode(ErrorData.self, from: data)
                        return completionHandler(.failure(NSError.serverError(code: errorModel.code, message: errorModel.message)))
                    } catch {
                        let unknownError = NSError.serverError(code: (response as? HTTPURLResponse)?.statusCode ?? 0, message: "Unspecified server error occurred")
                        return completionHandler(.failure(unknownError))
                    }
            }

            return completionHandler(.success(ResponseData(data, httpResponse)))
        }
    }
}
