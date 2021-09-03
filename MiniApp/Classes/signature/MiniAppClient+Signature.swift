import Foundation

extension MiniAppClient {
    @objc internal func verifySignature(version: String, signature: String, keyId: String, data: Data, handler: @escaping (Bool) -> Void) {
        if let baseUrl = environment.baseUrl {
            SignatureVerifier(fetcher: SignatureFetcher(apiClient: SignatureAPI(),
                                                   config: .init(baseURL: baseUrl, subscriptionKey: environment.subscriptionKey)),
                                  keyStore: SignatureKeyStore(account: baseUrl.identifier))
                    .verify(signature: signature, for: version, keyId: keyId, data: data, resultHandler: handler)
        }
    }
}
