internal class MetaDataDownloader {

    var manifestCache: MAManifestCache

    init() {
        self.manifestCache = MAManifestCache()
    }

    func getMiniAppMetaInfo(miniAppId: String, miniAppVersion: String, apiClient: MiniAppClient, completionHandler: @escaping (Result<MiniAppManifest, MASDKError>) -> Void) {

        guard let manifest = getCachedManifest(miniAppId: miniAppId, miniAppVersion: miniAppVersion), !apiClient.environment.isPreviewMode else {
            apiClient.getMiniAppMetaData(appId: miniAppId, versionId: miniAppVersion) { (result) in
                switch result {
                case .success(let responseData):
                    guard let decodeResponse = ResponseDecoder.decode(decodeType: MetaDataResponse.self,
                        data: responseData.data) else {
                        return completionHandler(.failure(.invalidResponseData))
                    }
                    let manifest = self.prepareMiniAppManifest(metaDataResponse: decodeResponse.bundleManifest, versionId: miniAppVersion)
                    self.manifestCache.saveManifestInfo(forMiniApp: miniAppId,
                        versionId: miniAppVersion,
                        manifest: CachedMetaData(version: miniAppVersion, miniAppManifest: manifest)
                    )
                    return completionHandler(.success(manifest))
                case .failure(let error):
                    return completionHandler(.failure(.fromError(error: error)))
                }
            }
            return
        }
        completionHandler(.success(manifest))
    }

    func getCachedManifest(miniAppId: String, miniAppVersion: String) -> MiniAppManifest? {
        return self.manifestCache.getManifestInfo(forMiniApp: miniAppId, versionId: miniAppVersion)?.miniAppManifest
    }

    func prepareMiniAppManifest(metaDataResponse: MetaDataCustomPermissionModel, versionId: String) -> MiniAppManifest {
        return MiniAppManifest(requiredPermissions: getCustomPermissionModel(metaDataCustomPermissionResponse: metaDataResponse.reqPermissions),
            optionalPermissions: getCustomPermissionModel(
                metaDataCustomPermissionResponse: metaDataResponse.optPermissions),
            customMetaData: metaDataResponse.customMetaData,
            accessTokenPermissions: metaDataResponse.accessTokenPermissions,
            versionId: versionId)
    }

    private func getCustomPermissionModel(metaDataCustomPermissionResponse: [MACustomPermissionsResponse]?) -> [MASDKCustomPermissionModel]? {
        return metaDataCustomPermissionResponse?.compactMap {
            guard let name = $0.name, let permissionType = MiniAppCustomPermissionType(rawValue: name) else {
                return nil
            }
            return MASDKCustomPermissionModel(permissionName: permissionType, isPermissionGranted: .allowed, permissionRequestDescription: $0.reason)
        }
    }
}
