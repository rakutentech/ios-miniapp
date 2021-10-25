import Quick
import Nimble
@testable import MiniApp

class MimeTypesTests: QuickSpec {

    override func spec() {
        describe("Mime Type Tests") {
            context("when mimeType is called with valid file path extension") {
                it("will return valid Mime Type") {
                    let htmlURL = URL(string: "\(mockHost)/home.svg")
                    expect(htmlURL?.pathExtension.mimeType()).to(equal("image/svg+xml"))
                }
            }
            context("when mimeType is called with valid file path extension - uppercased") {
                it("will return valid Mime Type") {
                    let htmlURL = URL(string: "\(mockHost)/index.HTML")
                    expect(htmlURL?.pathExtension.mimeType()).to(equal("text/html"))
                }
            }
            context("when mimeType is called with invalid file path extension") {
                it("will return default valid Mime Type") {
                    let htmlURL = URL(string: "\(mockHost)/index.abcd")
                    expect(htmlURL?.pathExtension.mimeType()).to(equal("text/html"))
                }
            }
        }
    }
}
