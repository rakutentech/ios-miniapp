internal class ManifestDownloader {

    func fetchManifest(apiClient: MiniAppClient,
                       appId: String,
                       versionId: String,
                       completionHandler: @escaping (Result<ManifestResponse, MASDKError>) -> Void) {

        apiClient.getAppManifest(appId: appId, versionId: versionId) { (result) in
            switch result {
            case .success(let responseData):
                guard let decodeResponse = ResponseDecoder.decode(decodeType: ManifestResponse.self, data: responseData.data) else {
                    return completionHandler(.failure(.invalidResponseData))
                }
                return completionHandler(.success(decodeResponse))
            case .failure(let error):
                return completionHandler(.failure(error))
            }
        }
    }
}
