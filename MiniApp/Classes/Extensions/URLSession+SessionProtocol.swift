extension URLSession: SessionProtocol {
    func startDataTask(with request: URLRequest, completionHandler: @escaping (Result<ResponseData, Error>) -> Void) {
        dataTask(with: request) { (data, response, error) in
            if let error = error {
                return completionHandler(.failure(error))
            }
            guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                let error = NSError(domain: "APIClient", code: (response as? HTTPURLResponse)?.statusCode ?? 0, userInfo: [NSLocalizedDescriptionKey: "Unknown server error occurred"])
                return completionHandler(.failure(error))
            }
            return completionHandler(.success(ResponseData(data, httpResponse)))
        }.resume()
    }
}
