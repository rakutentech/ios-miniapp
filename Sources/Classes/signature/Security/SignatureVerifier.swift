internal final class SignatureVerifier {

    let keyStore: SignatureKeyStore
    private var fetcher: SignatureFetcher
    private let verifier: Verifiable

    init(fetcher: SignatureFetcher,
         keyStore: SignatureKeyStore,
         verifier: Verifiable = Verifier()) {

        self.fetcher = fetcher
        self.keyStore = keyStore
        self.verifier = verifier
    }

    /// Verifies signature of given data using public key with given id
    /// - Parameter signature: Signature to be verified encoded in base64
    /// - Parameter: version: The id of the MiniApp version to be verified
    /// - Parameter keyId: ID of public key to be fetched
    /// - Parameter data: Data to be verified
    /// - Parameter resultHandler: Handler called when verification is complete
    func verify(signature: String,
                for version: String,
                keyId: String,
                data: Data,
                resultHandler: @escaping (Bool) -> Void) {
        let newSignature = version + data.sha256String()
        if let key = keyStore.key(for: keyId) {
            let result = verifier.verify(signatureBase64: signature,
                                         objectData: newSignature.data(using: .utf8) ?? data,
                                         keyBase64: key)
            resultHandler(result)
        } else {
            fetcher.fetchKey(with: keyId) { result in
                switch result {
                case .success(let keyModel):
                    guard keyModel.identifier == keyId else {
                        return resultHandler(false)
                    }
                    self.keyStore.addKey(key: keyModel.key, for: keyId)
                    let verified = self.verifier.verify(signatureBase64: signature,
                                                        objectData: newSignature.data(using: .utf8) ?? data,
                                                        keyBase64: keyModel.key)
                    resultHandler(verified)
                case .failure:
                    resultHandler(false)
                }
            }
        }
    }
}
