import Foundation

internal class MiniAppPermissionsStorage {

    typealias KeysDictionary = [String: [MASDKCustomPermissionModel]]
    let keychainStore = MiniAppKeyChain(serviceName: .customPermission)

    func getCustomPermissions(forMiniApp keyId: String) -> [MASDKCustomPermissionModel] {
        guard let allKeys = retrieveAllPermissions(), let permissionList = allKeys[keyId] as [MASDKCustomPermissionModel]? else {
            return []
        }
        return permissionList
    }

    func storeCustomPermissions(permissions: [MASDKCustomPermissionModel], forMiniApp keyId: String) {
        guard !keyId.isEmpty else {
            return
        }
        var keysDic = retrieveAllPermissions()
        var cachedPermissions = self.getCustomPermissions(forMiniApp: keyId)
        _ = permissions.map { (permissionModel: MASDKCustomPermissionModel) -> MASDKCustomPermissionModel in
            if let index = cachedPermissions.firstIndex(of: permissionModel) {
                cachedPermissions[index] = permissionModel
            } else {
                cachedPermissions.append(permissionModel)
            }
            permissionModel.permissionDescription = ""
            return permissionModel
        }
        if keysDic != nil {
            keysDic?[keyId] = cachedPermissions
        } else {
            keysDic = [keyId: cachedPermissions]
        }

        if let keys = keysDic {
            keychainStore.setInfoInKeyChain(keys: keys)
        }
    }

    /// Returns all key and values that is stored in Keychain,
    /// - Returns: List of KeysDictionary
    func getAllStoredCustomPermissionsList() -> KeysDictionary? {
        retrieveAllPermissions()
    }

    /// Remove Key from the KeyChain
    /// - Parameter keyId: Mini app ID
    internal func removeKey(for keyId: String) {
        var keysDic = retrieveAllPermissions()

        keysDic?[keyId] = nil

        if let keys = keysDic {
            keychainStore.setInfoInKeyChain(keys: keys)
        }
    }

    private func retrieveAllPermissions() -> KeysDictionary? {
        guard let storedData = keychainStore.getAllKeys() else {
            return nil
        }

        guard let keys = ResponseDecoder.decode(decodeType: KeysDictionary.self, data: storedData) else {
            return nil
        }

        return keys
    }

    internal func purgePermissions() {
        keychainStore.purge()
    }
}
