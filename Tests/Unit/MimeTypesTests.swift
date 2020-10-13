import Quick
import Nimble
@testable import MiniApp

class MimeTypesTests: QuickSpec {

    override func spec() {
        describe("Mime Type Tests") {
            context("when mimeType is called with valid file path extension") {
                it("will return valid Mime Type") {
                    let htmlURL = URL(string: "https://example.com/home.svg")
                    expect(htmlURL?.pathExtension.mimeType()).toEventually(equal("image/svg+xml"), timeout: .seconds(10))
                }
            }
            context("when mimeType is called with valid file path extension - uppercased") {
                it("will return valid Mime Type") {
                    let htmlURL = URL(string: "https://example.com/index.HTML")
                    expect(htmlURL?.pathExtension.mimeType()).toEventually(equal("text/html"), timeout: .seconds(10))
                }
            }
            context("when mimeType is called with invalid file path extension") {
                it("will return default valid Mime Type") {
                    let htmlURL = URL(string: "https://example.com/index.abcd")
                    expect(htmlURL?.pathExtension.mimeType()).toEventually(equal("text/html"), timeout: .seconds(10))
                }
            }
        }
    }
}
