import Foundation

internal class PreviewMiniAppFetcher {

    func fetchPreviewMiniAppInfo(apiClient: MiniAppClient, using token: String, completionHandler: @escaping (Result<PreviewMiniAppInfo, MASDKError>) -> Void) {
        apiClient.getPreviewMiniAppInfo(using: token) { (result) in
            switch result {
            case .success(let responseData):
                guard let decodeResponse = ResponseDecoder.decode(decodeType: PreviewMiniAppInfo.self, data: responseData.data) else {
                    return completionHandler(.failure(.invalidResponseData))
                }
                return completionHandler(.success(decodeResponse))
            case .failure(let error):
                return completionHandler(.failure(error))
            }
        }
    }
}
