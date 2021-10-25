import Quick
import Nimble
@testable import MiniApp

// swiftlint:disable function_body_length
class KeyStoreSpec: QuickSpec {
    #if RMA_SDK_SIGNATURE
    override func spec() {

        describe("KeyStore") {
            let keyStore = SignatureKeyStore(account: "https.endpoint.com.keys", service: "unit-tests")

            beforeEach {
                keyStore.empty()
            }

            context("when keystore is initially empty") {
                it("can retrieve an added key") {
                    keyStore.addKey(key: "a-key", for: "key-id")

                    expect(keyStore.key(for: "key-id")).to(equal("a-key"))
                }

                it("returns nil when attempt to retrieve a key not in keystore") {
                    keyStore.addKey(key: "a-key", for: "key-id")

                    expect(keyStore.key(for: "key-id-2")).to(beNil())
                }

                it("can retrieve a key that has been added twice") {
                    keyStore.addKey(key: "a-key", for: "key-id")
                    keyStore.addKey(key: "a-key", for: "key-id")

                    expect(keyStore.key(for: "key-id")).to(equal("a-key"))
                }
            }

            context("when keystore has multiple keys") {
                beforeEach {
                    keyStore.addKey(key: "a-key-1", for: "key-id-1")
                    keyStore.addKey(key: "a-key-2", for: "key-id-2")
                    keyStore.addKey(key: "a-key-3", for: "key-id-3")
                }

                it("can retrieve a key") {
                    expect(keyStore.key(for: "key-id-1")).to(equal("a-key-1"))
                }

                it("returns nil when attempt to retrieve a key not in keystore") {
                    expect(keyStore.key(for: "key-id-4")).to(beNil())
                }
            }

            context("when there is another keystore created with different account") {
                let keyStore2 = SignatureKeyStore(account: "https.endpoint.com.v2.keys", service: "unit-tests")
                beforeEach {
                    keyStore2.empty()
                }

                it("will store a value only in called keystore") {
                    keyStore.addKey(key: "a-key-1", for: "key-id-1")
                    expect(keyStore2.key(for: "key-id-1")).to(beNil())
                }

                it("will store values for the same key independently") {
                    keyStore.addKey(key: "a-key-1", for: "key-id-1")
                    keyStore2.addKey(key: "a-key-1-v2", for: "key-id-1")
                    expect(keyStore.key(for: "key-id-1")).to(equal("a-key-1"))
                    expect(keyStore2.key(for: "key-id-1")).to(equal("a-key-1-v2"))
                }
            }

            context("when there is another keystore created with the same account") {
                let keyStore2 = SignatureKeyStore(account: "https.endpoint.com.keys", service: "unit-tests")

                it("stored value in called keystore will be accessible from the other keystore") {
                    keyStore.addKey(key: "a-key-1", for: "key-id-1")
                    expect(keyStore2.key(for: "key-id-1")).to(equal("a-key-1"))
                }

                it("will override values for the same key") {
                    keyStore.addKey(key: "a-key-1", for: "key-id-1")
                    keyStore2.addKey(key: "a-key-1-v2", for: "key-id-1")
                    expect(keyStore.key(for: "key-id-1")).to(equal("a-key-1-v2"))
                    expect(keyStore2.key(for: "key-id-1")).to(equal("a-key-1-v2"))
                }
            }
        }
    }
    #endif
}
