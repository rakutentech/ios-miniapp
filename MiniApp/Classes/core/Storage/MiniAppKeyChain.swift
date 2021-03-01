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
        return retrieve()
    }

    // MARK: - Methods used to set & get values from Keychain
    private func write(data: Data) {
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

    private func retrieve() -> Data? {
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
    case accessTokenPermission = "rakuten.tech.scope.keys"
    case cacheVerifier = "rakuten.tech.keys"
}
