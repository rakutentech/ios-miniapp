internal class MetaDataDownloader {

    var manifestManager: MAManifestStorage

    init() {
        manifestManager = MAManifestStorage()
    }

    func getMiniAppMetaInfo(miniAppId: String, miniAppVersion: String, apiClient: MiniAppClient, completionHandler: @escaping (Result<MiniAppManifest, MASDKError>) -> Void) {
        guard let manifest = getCachedManifest(miniAppId: miniAppId), !apiClient.environment.isPreviewMode else {
            apiClient.getMiniAppMetaData(appId: miniAppId, versionId: miniAppVersion) { (result) in
                switch result {
                case .success(let responseData):
                    guard let decodeResponse = ResponseDecoder.decode(decodeType: MetaDataResponse.self,
                        data: responseData.data) else {
                        return completionHandler(.failure(.invalidResponseData))
                    }
                    let manifest = self.manifestManager.prepareMiniAppManifest(metaDataResponse: decodeResponse.bundleManifest, versionId: miniAppVersion)
                    if !apiClient.environment.isPreviewMode {
                        self.manifestManager.saveManifestInfo(forMiniApp: miniAppId, manifest: manifest)
                    }
                    return completionHandler(.success(manifest))
                case .failure(let error):
                    /// In Preview mode & when the internet connection is offline, the following code will try to return the cached manifest for that particular version.
                    let manifestError  = error as NSError
                    guard let manifest = self.getCachedManifest(miniAppId: miniAppId), manifestError.isDeviceOfflineError() else {
                        return completionHandler(.failure(.fromError(error: error)))
                    }
                    return completionHandler(.success(manifest))
                }
            }
            return
        }
        completionHandler(.success(manifest))
    }

    func getCachedManifest(miniAppId: String) -> MiniAppManifest? {
        manifestManager.getManifestInfo(forMiniApp: miniAppId)
    }

    func prepareMiniAppManifest(metaDataResponse: MetaDataCustomPermissionModel, versionId: String) -> MiniAppManifest {
        MiniAppManifest(
                requiredPermissions: getCustomPermissionModel(metaDataCustomPermissionResponse: metaDataResponse.reqPermissions),
                optionalPermissions: getCustomPermissionModel(
                        metaDataCustomPermissionResponse: metaDataResponse.optPermissions),
                customMetaData: metaDataResponse.customMetaData,
                accessTokenPermissions: metaDataResponse.accessTokenPermissions,
                versionId: versionId)
    }

    private func getCustomPermissionModel(metaDataCustomPermissionResponse: [MACustomPermissionsResponse]?) -> [MASDKCustomPermissionModel]? {
        metaDataCustomPermissionResponse?.compactMap {
            guard let name = $0.name, let permissionType = MiniAppCustomPermissionType(rawValue: name) else {
                return nil
            }
            return MASDKCustomPermissionModel(permissionName: permissionType, isPermissionGranted: .allowed, permissionRequestDescription: $0.reason)
        }

    }
}
