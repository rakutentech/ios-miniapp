import Foundation
import CommonCrypto

internal class MAManifestCache {

    typealias KeysDictionary = [String: [String: CachedMetaData]]
    let keychainStore = MiniAppKeyChain(serviceName: .miniAppManifestCache)
    let cacheName = "ManifestCache"
    func saveManifestInfo(forMiniApp appId: String, versionId: String, manifest: CachedMetaData) {
        guard !appId.isEmpty && !versionId.isEmpty else {
            return
        }
        keychainStore.setInfoInKeyChain(keys: [cacheName: [appId + "/" + versionId: manifest]])
    }

    func getManifestInfo(forMiniApp appId: String, versionId: String) -> CachedMetaData? {
        guard !appId.isEmpty && !versionId.isEmpty else {
            return nil
        }
        guard let allKeys = retrieveAllManifestInfo(), let manifestInfo = allKeys[cacheName], let key = manifestInfo.keys.first else {
            return nil
        }
        if key == (appId + "/" + versionId) {
            return manifestInfo.values.first
        } else {
            return nil
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
