import Foundation

@objc class MiniAppKeyChain: NSObject {
    let service: String
    var account: String

    init(service: String = Bundle.main.bundleIdentifier!, serviceName: ServiceName = .customPermission) {
        self.service = service
        self.account = "\(service).\(serviceName)"
    }

    internal func setInfoInKeyChain<T: Encodable>(keys: [String: T]) {
        guard let data = try? JSONEncoder().encode(keys) else {
            return
        }
        write(data: data)
    }

    internal func getAllKeys() -> Data? {
        retrieve()
    }

    // MARK: - Methods used to set & get values from Keychain
    private func write(data: Data) {
        let queryFind: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ]

        let update: [CFString: Any] = [
            kSecValueData: data
        ]

        var status = SecItemUpdate(queryFind as CFDictionary, update as CFDictionary)

        if status == errSecItemNotFound {
            let queryAdd: [CFString: Any] = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrService: service,
                kSecAttrAccount: account,
                kSecValueData: data,
                kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            ]
            status = SecItemAdd(queryAdd as CFDictionary, nil)
        }

        if let error = SecCopyErrorMessageString(status, nil) as String? {
            MiniAppLogger.d("SignatureKeyStore write status: \(error) [\(account)]", "🔐\(status == errSecSuccess ? "" : "⚠️")")
        }
    }

    private func retrieve() -> Data? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if let error = SecCopyErrorMessageString(status, nil) as String? {
            MiniAppLogger.d("SignatureKeyStore retrieve status: \(error) [\(account)]", "🔐\(status == errSecSuccess ? "" : "⚠️")")
        }
        guard status == errSecSuccess, let objectData = result as? Data else {
            return nil
        }
        return objectData
    }

    func purge() {
        let spec: NSDictionary = [kSecClass: kSecClassGenericPassword,
                                      kSecAttrService: service,
                                      kSecAttrAccount: account]
        let status = SecItemDelete(spec)
        if status != errSecSuccess, let error = SecCopyErrorMessageString(status, nil) as String? {
            MiniAppLogger.d("SignatureKeyStore purge status: \(error) [\(account)]", "🔐\(status == errSecSuccess ? "" : "⚠️")")
        }
    }
}

internal enum ServiceName: String {
    case customPermission = "rakuten.tech.permission.keys"
    case miniAppManifest = "rakuten.tech.manifest.keys"
    case miniAppManifestCache = "rakuten.tech.manifest.cache.keys"
    case cacheVerifier = "rakuten.tech.keys"
}
