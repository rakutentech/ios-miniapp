internal class SignatureAPI {
    let session: SessionType

    init(session: SessionType = URLSession(configuration: URLSessionConfiguration.default)) {
        self.session = session
    }

    func send(request: URLRequest,
              completionHandler: @escaping (Result<KeyModel, Error>) -> Void) {

        session.startTask(with: request) { (data, response, error) in

            if let payloadData = data,
               let object = try? JSONDecoder().decode(KeyModel.self, from: payloadData) {
                return completionHandler(.success(object))
            }

            // Error handling:
            // first, check for OS-level error
            // then, for a decodable server error object
            // then if no server error object is found, handle as unspecified error
            if let err = error {
                return completionHandler(.failure(err))
            }

            do {
                let errorModel = try JSONDecoder().decode(SignatureAPIError.self, from: data ?? Data())
                return completionHandler(.failure(NSError.serverError(code: errorModel.code, message: errorModel.message)))
            } catch {
                let serverError = NSError.serverError(
                    code: (response as? HTTPURLResponse)?.statusCode ?? 0,
                    message: "Unspecified server error occurred")
                MiniAppLogger.e("Error: \(serverError.description)")
                return completionHandler(.failure(serverError))
            }
        }
    }
}

private struct SignatureAPIError: Decodable, Equatable {
    let code: Int
    let message: String
}
