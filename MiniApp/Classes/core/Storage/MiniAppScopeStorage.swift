import Foundation

internal class MiniAppScopeStorage {

    typealias KeysDictionary = [String: [AccessTokenPermission]]
    let keychainStore = MiniAppKeyChain(serviceName: .accessTokenPermission)

    func getScopes(forMiniApp keyId: String) -> [AccessTokenPermission] {
        guard let allKeys = retrieveAllScopes(), let scopeList = allKeys[keyId] as [AccessTokenPermission]? else {
            return [AccessTokenPermission]()
        }
        return scopeList
    }

    func setScopes(scopes: [AccessTokenPermission], forMiniApp keyId: String) {
        guard !keyId.isEmpty else {
            return
        }
        var keysDic = retrieveAllScopes()
        keysDic?.removeValue(forKey: keyId)

        if keysDic != nil {
            keysDic?[keyId] = scopes
        } else {
            keysDic = [keyId: scopes]
        }

        if let keys = keysDic {
            keychainStore.setInfoInKeyChain(keys: keys)
        }
    }

    /// Returns all key and values that is stored in Keychain,
    /// - Returns: List of KeysDictionary
    func getAllStoredScopesList() -> KeysDictionary? {
        retrieveAllScopes()
    }

    /// Remove Key from the KeyChain
    /// - Parameter keyId: Mini app ID
    internal func removeKey(for keyId: String) {
        var keysDic = retrieveAllScopes()

        keysDic?[keyId] = nil

        if let keys = keysDic {
            keychainStore.setInfoInKeyChain(keys: keys)
        }
    }

    private func retrieveAllScopes() -> KeysDictionary? {
        guard let storedData = keychainStore.getAllKeys() else {
            return nil
        }

        guard let keys = ResponseDecoder.decode(decodeType: KeysDictionary.self, data: storedData) else {
            return nil
        }

        return keys
    }
}
