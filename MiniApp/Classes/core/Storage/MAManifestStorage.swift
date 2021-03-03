import Foundation
import CommonCrypto

internal class MAManifestStorage {

    typealias KeysDictionary = [String: MiniAppManifest]
    let keychainStore = MiniAppKeyChain(serviceName: .customPermission)

    func saveManifestInfo(forMiniApp appId: String, manifest: MiniAppManifest) {
        guard !appId.isEmpty else {
            return
        }
        var keysDic = retrieveAllManifestInfo()
        if keysDic != nil {
            keysDic?[appId] = manifest
        } else {
            keysDic = [appId: manifest]
        }

        if let keys = keysDic {
            keychainStore.setInfoInKeyChain(keys: keys)
        }
    }

    func getManifestInfo(forMiniApp appId: String) -> MiniAppManifest? {
        guard !appId.isEmpty else {
            return nil
        }
        guard let allKeys = retrieveAllManifestInfo(), let manifestInfo = allKeys[appId] as MiniAppManifest? else {
            return nil
        }
        return manifestInfo
    }

    /// Remove Key from the KeyChain
    /// - Parameter keyId: Mini app ID
    internal func removeKey(forMiniApp appId: String) {
        var keysDic = retrieveAllManifestInfo()

        keysDic?[appId] = nil

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
