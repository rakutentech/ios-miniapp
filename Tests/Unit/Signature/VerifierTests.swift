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
