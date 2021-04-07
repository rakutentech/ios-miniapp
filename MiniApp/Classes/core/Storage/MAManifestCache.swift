import Foundation
import CommonCrypto

internal class MAManifestCache {

    typealias KeysDictionary = [String: CachedMetaData]
    let keychainStore = MiniAppKeyChain(serviceName: .miniAppManifestCache)

    func saveManifestInfo(forMiniApp appId: String, versionId: String, manifest: CachedMetaData) {
        guard !appId.isEmpty && !versionId.isEmpty else {
            return
        }
        var keysDic = retrieveAllManifestInfo()
        if keysDic != nil {
            keysDic?[appId + "/" + versionId] = manifest
        } else {
            keysDic = [appId + "/" + versionId: manifest]
        }

        if let keys = keysDic {
            keychainStore.setInfoInKeyChain(keys: keys)
        }
    }

    func getManifestInfo(forMiniApp appId: String, versionId: String) -> CachedMetaData? {
        guard !appId.isEmpty && !versionId.isEmpty else {
            return nil
        }
        guard let allKeys = retrieveAllManifestInfo(), let manifestInfo = allKeys[appId + "/" + versionId] as CachedMetaData? else {
            return nil
        }
        return manifestInfo
    }

    /// Remove Key from the KeyChain
    /// - Parameter keyId: Mini app ID
    internal func removeKey(forMiniApp appId: String, versionId: String) {
        var keysDic = retrieveAllManifestInfo()

        keysDic?[appId + "/" + versionId] = nil

        if let keys = keysDic {
            keychainStore.setInfoInKeyChain(keys: keys)
        }
    }

    private func retrieveAllManifestInfo() -> KeysDictionary? {
        guard let storedData = keychainStore.getAllKeys() else {
            return nil
        }

        guard let keys = ResponseDecoder.decode(decodeType: KeysDictionary.self, data: storedData) else {
            return nil
        }

        return keys
    }

}
