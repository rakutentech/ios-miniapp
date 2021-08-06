import Foundation
import CommonCrypto

internal class MiniAppVerificationStorage {

    typealias CacheVerifierKeysDictionary = [String: String]
    let keychainStore = MiniAppKeyChain(serviceName: .cacheVerifier)

    func setCacheVerificationInfo(key: String, for keyId: String) {
        var keysDic = getAllCacheKeys()
        guard keysDic?[keyId] == nil else {
            return // key exists
        }

        if keysDic != nil {
            keysDic?[keyId] = key
        } else {
            keysDic = [keyId: key]
        }

        if let keys = keysDic {
            keychainStore.setInfoInKeyChain(keys: keys)
        }
    }

    func getCacheVerificationInfo(for keyId: String) -> String? {
        return getAllCacheKeys()?[keyId]
    }

    private func getAllCacheKeys() -> CacheVerifierKeysDictionary? {
        guard let storedData = keychainStore.getAllKeys() else {
            return nil
        }

        guard let keys = try? JSONSerialization.jsonObject(with: storedData, options: []) as? CacheVerifierKeysDictionary else {
            return nil
        }

        return keys
    }

    func removeCacheInfo(for keyId: String) {
        var keysDic = getAllCacheKeys()

        keysDic?[keyId] = nil

        if let keys = keysDic {
            keychainStore.setInfoInKeyChain(keys: keys)
        }
    }

    internal func purgeVerifications() {
        keychainStore.purge()
    }
}
