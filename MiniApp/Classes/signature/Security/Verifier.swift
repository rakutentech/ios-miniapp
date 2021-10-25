protocol Verifiable {
    func verify(signatureBase64: String, objectData: Data, keyBase64: String) -> Bool
}

internal struct Verifier: Verifiable {

    func verify(signatureBase64: String,
                objectData: Data,
                keyBase64: String) -> Bool {

        MiniAppLogger.d("Verify data for \(String(data: objectData, encoding: .utf8) ?? "<nil>") with signature \(signatureBase64) and key \(keyBase64)", "🔏")
        guard let secKey = createSecKey(for: keyBase64),
            let signatureData = Data(base64Encoded: signatureBase64) else {
                return false
        }

        var error: Unmanaged<CFError>?
        let verified = SecKeyVerifySignature(secKey,
                                             .ecdsaSignatureMessageX962SHA256,
                                             objectData as CFData,
                                             signatureData as CFData,
                                             &error)
        MiniAppLogger.d("Signature verification: \(verified ? "🟢":"❌")", "🔏")
        if let err = error as? Error {
            MiniAppLogger.e("Signature verification error", err)
        }
        return verified
    }

    private func createSecKey(for base64String: String) -> SecKey? {
        let attributes: [String: Any] = [
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256
        ]
        guard let secKeyData = Data(base64Encoded: base64String) else {
            return nil
        }

        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(secKeyData as CFData, attributes as CFDictionary, &error) else {
            if let err = error?.takeRetainedValue() {
                MiniAppLogger.e(#function, err)
            }
            return nil
        }
        MiniAppLogger.d("Key created: \(String(describing: secKey))", "🔏")

        if !SecKeyIsAlgorithmSupported(secKey, .verify, .ecdsaSignatureMessageX962SHA256) {
            MiniAppLogger.e("Key doesn't support algorithm ecdsaSignatureMessageX962SHA256")
            return nil
        }
        return secKey
    }
}
