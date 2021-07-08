import Foundation
import CommonCrypto

internal class MAManifestStorage {
    typealias KeysDictionary = [String: Int]
    let keychainStore = MiniAppKeyChain(serviceName: .miniAppManifest)
    let fileName = "manifest.json"

    func prepareMiniAppManifest(metaDataResponse: MetaDataCustomPermissionModel, versionId: String) -> MiniAppManifest {
        MiniAppManifest(requiredPermissions: getCustomPermissionModel(metaDataCustomPermissionResponse: metaDataResponse.reqPermissions),
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

    func saveManifestInfo(forMiniApp appId: String, manifest: MiniAppManifest) {
        guard !appId.isEmpty else {
            return
        }
        save(miniAppManifest: manifest, appId: appId)
    }

    func getManifestInfo(forMiniApp appId: String) -> MiniAppManifest? {
        guard !appId.isEmpty else {
            return nil
        }
        if let cache = read(appId: appId), checkManifestInfo(cache, appId: appId) {
            return cache
        }
        return nil
    }

    /// Remove Key from the KeyChain
    /// - Parameter keyId: Mini app ID
    internal func removeKey(forMiniApp appId: String) {
        FileManager.default.remove(fileName, from: FileManager.getMiniAppDirectory(with: appId))
        removeManifestHash(for: appId)
    }

    internal func purgeManifestInfos() {
        purgeManifestHashes()
    }
}

// MARK: - ManifestStorage file storage
extension MAManifestStorage {
    private func documentDirectory() -> String {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                .userDomainMask,
                true)
        return documentDirectory[0]
    }

    private func append(toPath path: URL,
                        withPathComponent pathComponent: String) -> String? {
        var pathURL = path
        pathURL.appendPathComponent(pathComponent)
        return pathURL.absoluteString
    }

    private func read(appId: String) -> MiniAppManifest? {
        if let manifest = FileManager.default.retrieve(fileName, from: FileManager.getMiniAppDirectory(with: appId), as: MiniAppManifest.self) {
            MiniAppLogger.d("Manifest \(manifest.hashValue) retrieved", "📂 [MANIFEST]")
            return manifest
        }
        return nil
    }

    private func save(miniAppManifest: MiniAppManifest, appId: String) {
        let directory = FileManager.getMiniAppDirectory(with: appId)
        if !FileManager.default.fileExists(atPath: directory.path) {
            do {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            } catch {
                MiniAppLogger.e("Error creating \(directory.path)", error)
                return
            }
        }
        if FileManager.default.store(miniAppManifest, to: directory.path, as: fileName) {
            saveManifestHash(forMiniApp: appId, manifest: miniAppManifest)
            MiniAppLogger.d("Save successful for \(directory.appendingPathComponent(fileName).path)", "📂 [MANIFEST]")
        } else {
            MiniAppLogger.d("Save failed for \(directory.appendingPathComponent(fileName).path)", "📂 [MANIFEST]")
        }

    }
}

// MARK: - ManifestStorage hashes storage
extension MAManifestStorage {
    func saveManifestHash(forMiniApp appId: String, manifest: MiniAppManifest) {
        guard !appId.isEmpty else {
            return
        }
        var keys = retrieveAllManifestHashes()
        keys[appId] = manifest.hashValue
        MiniAppLogger.d("Saving keys[\(appId)] == \(keys[appId] ?? 0)", "🔐 [MANIFEST]")

        keychainStore.setInfoInKeyChain(keys: keys)
    }

    func checkManifestInfo(_  manifest: MiniAppManifest, appId: String) -> Bool {
        let allKeys = retrieveAllManifestHashes()
        guard !appId.isEmpty,
              let manifestHash = allKeys[appId] else {
            return false
        }
        MiniAppLogger.d("Checking hash \(manifestHash) == \(manifest.hashValue)", "🔐 [MANIFEST]")
        return manifestHash == manifest.hashValue
    }

    private func retrieveAllManifestHashes() -> KeysDictionary {
        guard let storedData = keychainStore.getAllKeys() else {
            return [:]
        }
        guard let keys = ResponseDecoder.decode(decodeType: KeysDictionary.self, data: storedData) else {
            return [:]
        }
        return keys
    }

    private func removeManifestHash(for appId: String) {
        guard !appId.isEmpty else {
            return
        }
        var keys = retrieveAllManifestHashes()
        MiniAppLogger.d("Removing keys[\(appId)] = \(keys[appId] ?? 0)", "🔐 [MANIFEST]")

        keys.removeValue(forKey: appId)
        keychainStore.setInfoInKeyChain(keys: keys)
    }

    internal func purgeManifestHashes() {
        keychainStore.purge()
    }
}
