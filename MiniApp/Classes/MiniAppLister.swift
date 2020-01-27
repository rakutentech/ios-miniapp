internal class MiniAppLister {

    func fetchList(apiClient: MiniAppClient, completionHandler: @escaping (Result<[MiniAppInfo], Error>) -> Void) {

        apiClient.getMiniAppsList { (result) in
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

    func decodeListingResponse(with dataResponse: Data) -> [MiniAppInfo]? {
        do {
            return try JSONDecoder().decode(Array<MiniAppInfo>.self, from: dataResponse) as [MiniAppInfo]
        } catch let error {
            print("Decoding Failed with Error: ", error)
            return nil
        }
    }

    func invalidResponseData() -> NSError {
        return NSError(domain: "Server Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response received"])
    }
}
