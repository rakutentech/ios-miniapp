import Foundation

@objc class MiniAppKeyChain: NSObject {
    let service: String
    var account: String

    typealias CacheVerifierKeysDictionary = [String: String]
    typealias KeysDictionary = [String: [MASDKCustomPermissionModel]]

    init(service: String = Bundle.main.bundleIdentifier!, serviceName: ServiceName = .customPermission) {
        self.service = service
        self.account = "\(service).\(serviceName)"
    }

    // MARK: - Custom permission methods
    func getCustomPermissions(forMiniApp keyId: String) -> [MASDKCustomPermissionModel] {
        guard let allKeys = retrieveAllPermissions(), let permissionList = allKeys[keyId] as [MASDKCustomPermissionModel]? else {
            return getDefaultSupportedPermissions()
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
                cachedPermissions[index].permissionDescription = ""
            }
            return permissionModel
        }

        if keysDic != nil {
            keysDic?[keyId] = cachedPermissions
        } else {
            keysDic = [keyId: cachedPermissions]
        }

        if let keys = keysDic {
            writePermissionInfo(keys: keys)
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
            writePermissionInfo(keys: keys)
        }
    }

    internal func getDefaultSupportedPermissions() -> [MASDKCustomPermissionModel] {
        var supportedPermissionList = [MASDKCustomPermissionModel]()
        MiniAppCustomPermissionType.allCases.forEach {
            supportedPermissionList.append(MASDKCustomPermissionModel(
                permissionName: MiniAppCustomPermissionType(
                    rawValue: $0.rawValue)!,
                isPermissionGranted: .denied,
                permissionRequestDescription: ""
            ))
        }
        return supportedPermissionList
    }

    private func writePermissionInfo(keys: KeysDictionary) {
        guard let data = try? JSONEncoder().encode(keys) else {
            return
        }
        setValueInKeyChain(data: data)
    }

    private func retrieveAllPermissions() -> KeysDictionary? {
        guard let storedData = getAllKeysFromKeychain() else {
            return nil
        }

        guard let keys = ResponseDecoder.decode(decodeType: KeysDictionary.self, data: storedData) else {
            return nil
        }

        return keys
    }

    // MARK: - Cache Verifier Methods
    internal func setCacheInfo(key: String, for keyId: String) {
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
            writeCacheInfo(keys: keys)
        }
    }

    internal func getCacheInfo(for keyId: String) -> String? {
        return getAllCacheKeys()?[keyId]
    }

    private func getAllCacheKeys() -> CacheVerifierKeysDictionary? {
        guard let storedData = getAllKeysFromKeychain() else {
            return nil
        }

        guard let keys = try? JSONSerialization.jsonObject(with: storedData, options: []) as? CacheVerifierKeysDictionary else {
            return nil
        }

        return keys
    }

    private func writeCacheInfo(keys: CacheVerifierKeysDictionary) {
        guard let data = try? JSONEncoder().encode(keys) else {
            return
        }
        setValueInKeyChain(data: data)
    }

    internal func removeCacheInfo(for keyId: String) {
        var keysDic = getAllCacheKeys()

        keysDic?[keyId] = nil

        if let keys = keysDic {
            writeCacheInfo(keys: keys)
        }
    }

    // MARK: - Methods used to set & get values from Keychain
    private func setValueInKeyChain(data: Data) {
        let queryFind: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let update: [String: Any] = [
            kSecValueData as String: data
        ]

        var status = SecItemUpdate(queryFind as CFDictionary, update as CFDictionary)

        if status == errSecItemNotFound {
            let queryAdd: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account,
                kSecValueData as String: data,
                kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            ]
            status = SecItemAdd(queryAdd as CFDictionary, nil)
        }

        if status != errSecSuccess {
            let error = SecCopyErrorMessageString(status, nil) as String?
            print("KeyStore write error \(String(describing: error))")
        }
    }

    private func getAllKeysFromKeychain() -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let objectData = result as? Data else {
            return nil
        }
        return objectData
    }
}

internal enum ServiceName: String {
    case customPermission = "rakuten.tech.permission.keys"
    case cacheVerifier = "rakuten.tech.keys"
}
