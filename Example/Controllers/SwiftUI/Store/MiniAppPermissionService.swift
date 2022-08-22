import Foundation
import MiniApp

@MainActor
final class MiniAppPermissionService {

    let config: MiniAppSdkConfig = Config.current()

    init() {
        // init
    }

    func getInfo(miniAppId: String, miniAppVersion: String, completion: @escaping ((Result<MiniAppInfo, MASDKError>) -> Void)) {
        MiniApp
        .shared(with: config)
        .info(miniAppId: miniAppId, miniAppVersion: miniAppVersion) { result in
            switch result {
            case .success(let info):
                completion(.success(info))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func getCachedManifest(miniAppId: String) -> MiniAppManifest? {
        MiniApp.shared(with: config).getDownloadedManifest(miniAppId: miniAppId)
    }

    // MARK: - Check Permissions
    func checkPermissions(
        config: MiniAppSdkConfig = Config.current(),
        miniAppId: String,
        miniAppVersion: String,
        completion: @escaping ((Result<PermissionState, Error>) -> Void)
    ) {
        MiniApp.shared(with: config).info(miniAppId: miniAppId, miniAppVersion: miniAppVersion) { [weak self] result in
            switch result {
            case .success(let info):
                self?.checkPermissions(
                    config: config,
                    miniAppInfo: info,
                    completion: completion
                )
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func checkPermissions(
        config: MiniAppSdkConfig = Config.current(),
        miniAppInfo: MiniAppInfo,
        completion: @escaping ((Result<PermissionState, Error>) -> Void)
    ) {
        if let cachedManifest = MiniApp.shared(with: config).getDownloadedManifest(miniAppId: miniAppInfo.id) {
            compareMiniAppManifest(config: config, info: miniAppInfo, manifest: cachedManifest) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let isManifestSame):
                        if isManifestSame {
                            completion(.success(.permissionGranted))
                        } else {
                            completion(.success(.permissionRequested(info: miniAppInfo, manifest: cachedManifest)))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        } else {
            // show permission screen
            fetchMetaData(config: config, miniAppId: miniAppInfo.id, miniAppVersion: miniAppInfo.version.versionId) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let manifest):
                        completion(.success(.permissionRequested(info: miniAppInfo, manifest: manifest)))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }

    func compareMiniAppManifest(
        config: MiniAppSdkConfig,
        info: MiniAppInfo,
        manifest: MiniAppManifest,
        completion: @escaping ((Result<Bool, Error>) -> Void)
    ) {
        MiniApp
        .shared(with: config)
        .getMiniAppManifest(
            miniAppId: info.id,
            miniAppVersion: info.version.versionId,
            languageCode: NSLocale.current.languageCode
        ) { (result) in
            switch result {
            case .success(let manifestData):
                if manifest == manifestData {
                    completion(.success(true))
                } else {
                    completion(.success(false))
                }
            case .failure(let error):
                if error.isQPSLimitError() {
                    let title = MASDKLocale.localize("miniapp.sdk.ios.error.title")
                    let message = MASDKLocale.localize(.miniAppTooManyRequestsError)
                    completion(.failure(MiniAppViewError(title: title, message: message)))
                } else {
                    let title = MASDKLocale.localize("miniapp.sdk.ios.error.title")
                    let message = MASDKLocale.localize("miniapp.sdk.ios.error.message.single")
                    completion(.failure(MiniAppViewError(title: title, message: message)))
                }
            }
        }
    }

    func fetchMetaData(
        config: MiniAppSdkConfig,
        miniAppId: String,
        miniAppVersion: String,
        completion: @escaping ((Result<MiniAppManifest, Error>) -> Void)
    ) {
        MiniApp
        .shared(with: config)
        .getMiniAppManifest(
            miniAppId: miniAppId,
            miniAppVersion: miniAppVersion,
            languageCode: NSLocale.current.languageCode
        ) { (result) in
            switch result {
            case .success(let manifestData):
                completion(.success(manifestData))
            case .failure(let error):
                if error.isQPSLimitError() {
                    let title = MASDKLocale.localize("miniapp.sdk.ios.error.title")
                    let message = MASDKLocale.localize(.miniAppTooManyRequestsError)
                    completion(.failure(MiniAppViewError(title: title, message: message)))
                } else {
                    let title = MASDKLocale.localize("miniapp.sdk.ios.error.title")
                    let message = MASDKLocale.localize("miniapp.sdk.ios.error.message.single")
                    completion(.failure(MiniAppViewError(title: title, message: message)))
                }
            }
        }
    }

    // MARK: - Change Permissions
    func updatePermissions(miniAppId: String, manifest: MiniAppManifest) {
        let permissionsCollection = (manifest.requiredPermissions ?? []) + (manifest.optionalPermissions ?? [])
        MiniApp.shared(with: Config.current()).setCustomPermissions(forMiniApp: miniAppId, permissionList: permissionsCollection)
    }

    func updatePermissions(miniAppId: String, permissionList: [MASDKCustomPermissionModel]) {
        MiniApp.shared(with: Config.current()).setCustomPermissions(forMiniApp: miniAppId, permissionList: permissionList)
    }

    func updatePermissionsWithCache(miniAppId: String, permissions: [MASDKCustomPermissionModel]) -> [MASDKCustomPermissionModel] {
        let cachedPermissions = MiniApp.shared().getCustomPermissions(forMiniApp: miniAppId)
        for permission in permissions {
            if let cachedPerm = cachedPermissions.first(where: { $0.permissionName == permission.permissionName }) {
                permission.isPermissionGranted = cachedPerm.isPermissionGranted
            }
        }
        return permissions
    }
}

extension MiniAppPermissionService {
    enum ViewState: Equatable {
        static func == (lhs: ViewState, rhs: ViewState) -> Bool {
            switch (lhs, rhs) {
            case (.none, .none):
                return true
            case (.loading, .loading):
                return true
            case (.permissionRequested(let lhsInfo, let lhsManifest), .permissionRequested(let rhsInfo, let rhsManifest)):
                return lhsInfo.id == rhsInfo.id && lhsManifest.versionId == rhsManifest.versionId
            case (.error(let lhsError), .error(let rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            case (.success, .success):
                return true
            default:
                return false
            }
        }

        case none
        case loading
        case permissionRequested(info: MiniAppInfo, manifest: MiniAppManifest)
        case error(Error)
        case success
    }

    enum PermissionState {
        case permissionRequested(info: MiniAppInfo, manifest: MiniAppManifest)
        case permissionGranted
    }
}

extension MiniAppPermissionService {
    struct MiniAppViewError: Error {
        let title: String
        let message: String
    }
}
