extension URLSession: SessionProtocol {
    func startDataTask(with request: URLRequest, completionHandler: @escaping (Result<ResponseData, Error>) -> Void) {
        dataTask(with: request) { (data, response, error) in
            if let error = error {
                return completionHandler(.failure(error))
            }
            guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                let error = NSError.unknownServerError(httpResponse: response as? HTTPURLResponse)
                return completionHandler(.failure(error))
            }
            return completionHandler(.success(ResponseData(data, httpResponse)))
        }.resume()
    }
}
