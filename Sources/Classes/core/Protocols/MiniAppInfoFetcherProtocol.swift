import Foundation

protocol MiniAppInfoFetcherInterface {
    func fetchList(apiClient: MiniAppClientProtocol, completionHandler: @escaping (Result<[MiniAppInfo], MASDKError>) -> Void)
    func getInfo(miniAppId: String, miniAppVersion: String?, apiClient: MiniAppClientProtocol, completionHandler: @escaping (Result<MiniAppInfo, MASDKError>) -> Void)
}
