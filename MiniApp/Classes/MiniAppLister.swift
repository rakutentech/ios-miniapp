internal class MiniAppLister {

    func fetchList(apiClient: MiniAppClient, completionHandler: @escaping (Result<[MiniAppInfo], Error>) -> Void) {

        apiClient.getMiniAppsList { (result) in
            switch result {
            case .success(let responseData):
                guard let decodeResponse = ResponseDecoder.decode(decodeType: Array<MiniAppInfo>.self, data: responseData.data) else {
                    return completionHandler(.failure(NSError.invalidResponseData()))
                }
                return completionHandler(.success(decodeResponse))
            case .failure(let error):
                return completionHandler(.failure(error))
            }
        }
    }

    func fetchMiniApp(miniAppId: String, apiClient: MiniAppClient, completionHandler: @escaping (Result<MiniAppInfo, Error>) -> Void) {

        apiClient.getMiniApp(miniAppId) { (result) in
            switch result {
            case .success(let responseData):
                guard let decodeResponse = ResponseDecoder.decode(decodeType: Array<MiniAppInfo>.self, data: responseData.data), let miniApp = decodeResponse.first else {
                    return completionHandler(.failure(NSError.invalidResponseData()))
                }

                return completionHandler(.success(miniApp))

            case .failure(let error):
                return completionHandler(.failure(error))
            }
        }
    }
}
