import Quick
import Nimble
@testable import MiniApp

// Both Android and iOS SDKs receive and verify against the same crypto algos so we can
// reuse the key and signature generated for the Android tests:
// https://github.com/rakutentech/android-remote-config/blob/master/remote-config/src/test/kotlin/com/rakuten/tech/mobile/remoteconfig/verification/SignatureVerifierSpec.kt#L10

class VerifierSpec: QuickSpec {
    #if RMA_SDK_SIGNATURE
    override func spec() {
        let verifier = Verifier()
        let jsonData = (try? JSONSerialization.data(withJSONObject: ["testKey": "test_value"], options: []))!
        let signature = "MEUCIQCHJfSffJ+yjuCAvH3HKprbSn3XqUtZm9a+6+w2GILfywIgOkpFyaPNyQReaylbuhegQpPS+uVDwczbUsKZtaHcSnw="
        let key = "BI2zZr56ghnMLXBMeC4bkIVg6zpFD2ICIS7V6cWo8p8LkibuershO+Hd5ru6oBFLlUk6IFFOIVfHKiOenHLBNIY="

        it("should verify the signature of the original payload") {
            let verified = verifier.verify(signatureBase64: signature,
                                           objectData: jsonData,
                                           keyBase64: key)
            expect(verified).to(beTrue())
        }

        it("should not verify the signature of a corrupted payload") {
            let verified = verifier.verify(signatureBase64: "MEUCIQCHJfSffJ+yjuCAvH3HKprbSn3XqUtZm9a+6+w2GILfy",
                                           objectData: jsonData,
                                           keyBase64: key)
            expect(verified).to(beFalse())
        }

        it("should not verify the signature of a corrupted key") {
            let verified = verifier.verify(signatureBase64: signature,
                                           objectData: jsonData,
                                           keyBase64: "AI2zZr56ghnMLXBMeC4bkIVg6zpFD2ICIS7V6cWo8p8LkibuershO+Hd5ru6oBFLlUk6IFFOIVfHKiOenHLBNIY=")
            expect(verified).to(beFalse())
        }

        it("should not verify the signature of a key is not using the good algorithm") {
            let verified = verifier.verify(signatureBase64: signature,
                                           objectData: jsonData,
                                           keyBase64:
                                            """
                                            047542b07e0a2c6672d5ef2c89bd9e607fb12f581544341d135862b520410772b4c55ad37e5d
                                            461c1488c05e5bc9b3e03c35b42c1e64fc1bd2bcf248758b4ff84c8ab161d00a5ba2c58d9865
                                            5d901e54cc541bf6e57204bf80bb188e33c57872a1
                                            """)
            expect(verified).to(beFalse())
        }

        it("should not verify the signature of a modified payload") {
            let jsonData = (try? JSONSerialization.data(withJSONObject: ["testKey": "different_value"], options: []))!
            let verified = verifier.verify(signatureBase64: signature,
                                           objectData: jsonData,
                                           keyBase64: key)
            expect(verified).to(beFalse())
        }
    }
    #endif
}
