import Quick
import Nimble
@testable import MiniApp

class MASDKErrorTests: QuickSpec {
    override func spec() {
        describe("MASDKError tests") {
            context("when converting an NSError") {
                it("will convert server error") {
                    let originalError = NSError.serverError(code: 400, message: "test")
                    let newError = MASDKError.serverError(code: 400, message: "test")

                    expect(MASDKError.fromError(error: originalError).localizedDescription).to(equal(newError.localizedDescription))
                }

                it("will convert invalid URL error") {
                    let originalError = NSError.invalidURLError()
                    let newError = MASDKError.invalidURLError

                    expect(MASDKError.fromError(error: originalError).localizedDescription).to(equal(newError.localizedDescription))
                }

                it("will convert invalid App ID error") {
                    let originalError = NSError.invalidAppId()
                    let newError = MASDKError.invalidAppId

                    expect(MASDKError.fromError(error: originalError).localizedDescription).to(equal(newError.localizedDescription))
                }

                it("will convert invalid response data error") {
                    let originalError = NSError.invalidResponseData()
                    let newError = MASDKError.invalidResponseData

                    expect(MASDKError.fromError(error: originalError).localizedDescription).to(equal(newError.localizedDescription))
                }

                it("will convert invalid downloading failed error") {
                    let originalError = NSError.downloadingFailed()
                    let newError = MASDKError.downloadingFailed

                    expect(MASDKError.fromError(error: originalError).localizedDescription).to(equal(newError.localizedDescription))
                }

                it("will convert invalid no published version error") {
                    let originalError = NSError.noPublishedVersion()
                    let newError = MASDKError.noPublishedVersion

                    expect(MASDKError.fromError(error: originalError).localizedDescription).to(equal(newError.localizedDescription))
                }

                it("will convert invalid no mini app not found error") {
                    let originalError = NSError.miniAppNotFound(message: "")
                    let newError = MASDKError.miniAppNotFound

                    expect(MASDKError.fromError(error: originalError).localizedDescription).to(equal(newError.localizedDescription))
                }

                it("will convert return unknown error") {
                    let originalError = NSError(domain: "test_domain", code: 1, userInfo: [NSLocalizedDescriptionKey: "test_description"])
                    let newError = MASDKError.unknownError(domain: "test_domain", code: 1, description: "test_description")

                    expect(MASDKError.fromError(error: originalError).localizedDescription).to(equal(newError.localizedDescription))
                }
            }
        }
    }
}
