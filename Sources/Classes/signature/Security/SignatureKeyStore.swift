internal final class SignatureKeyStore {
    private let service: String
    private let account: String

    typealias KeysDictionary = [String: String]

    init(account: String, service: String = Bundle.main.bundleIdentifier!) {
        self.service = service
        self.account = "\(service).\(account).keys"
    }

    func key(for keyId: String) -> String? {
        getKeys()?[keyId]
    }

    func addKey(key: String, for keyId: String) {
        var keysDict = getKeys() ?? [:]

        keysDict[keyId] = key
        write(keys: keysDict)
    }

    func empty() {
        write(keys: [:])
    }

    private func write(keys: KeysDictionary) {
        guard let data = try? JSONSerialization.data(withJSONObject: keys, options: []) else {
            return
        }

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
            let error: String?
            error = SecCopyErrorMessageString(status, nil) as String?
            MiniAppLogger.e("SignatureKeyStore write error \(String(describing: error))")
        }
    }

    private func getKeys() -> KeysDictionary? {
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

        guard let keys = try? JSONSerialization.jsonObject(with: objectData, options: []) as? KeysDictionary else {
            return nil
        }

        return keys
    }
}
