import Foundation

internal class MiniAppInfoFetcher: MiniAppInfoFetcherInterface {

    func fetchList(apiClient: MiniAppClientProtocol, completionHandler: @escaping (Result<[MiniAppInfo], MASDKError>) -> Void) {

        apiClient.getMiniAppsList { (result) in
            switch result {
            case .success(let responseData):
                guard let decodeResponse = ResponseDecoder.decode(decodeType: Array<MiniAppInfo>.self, data: responseData.data) else {
                    return completionHandler(.failure(.invalidResponseData))
                }
                return completionHandler(.success(decodeResponse))
            case .failure(let error):
                return completionHandler(.failure(error))
            }
        }
    }

    func getInfo(miniAppId: String, miniAppVersion: String? = nil, apiClient: MiniAppClientProtocol, completionHandler: @escaping (Result<MiniAppInfo, MASDKError>) -> Void) {

        apiClient.getMiniApp(miniAppId) { (result) in
            switch result {
            case .success(let responseData):
                if let decodeResponse = ResponseDecoder.decode(decodeType: Array<MiniAppInfo>.self, data: responseData.data) {
                    let miniAppInfo: MiniAppInfo?
                    if let version = miniAppVersion {
                        miniAppInfo = decodeResponse.filter({ (appInfo) -> Bool in
                            appInfo.version.versionId == version
                        }).first
                    } else {
                        miniAppInfo = decodeResponse.first
                    }
                    if let miniApp = miniAppInfo {
                        return completionHandler(.success(miniApp))
                    } else {
                        return completionHandler(.failure(.noPublishedVersion))
                    }
                }
                return completionHandler(.failure(.invalidResponseData))
            case .failure(let error):
                if error.isQPSLimitError() {
                    MiniAppStorage.cleanVersions(for: miniAppId)
                }
                return completionHandler(.failure(error))
            }
        }
    }
}
