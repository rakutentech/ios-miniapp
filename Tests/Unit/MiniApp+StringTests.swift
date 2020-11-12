import Quick
import Nimble
@testable import MiniApp

class MiniAppStringTests: QuickSpec {

    override func spec() {
        describe("Mini app + String extension") {
            context("when localized key is passed that is available in Pod bundle") {
                it("will return valid localized string") {
                    let okLocalizedTitle = "Ok_title".localizedString()
                    expect(okLocalizedTitle).toEventually(equal("OK"), timeout: .seconds(10))
                }

                it("will return valid localized string") {
                    let cancelLocalizedTitle = "Cancel_title".localizedString()
                    expect(cancelLocalizedTitle).toEventually(equal("Cancel"), timeout: .seconds(10))
                }
            }
            context("when localized key is passed with pod bundle path as empty") {
                it("will return the key as string") {
                    let okLocalizedTitle = "Ok_title".localizedString(path: "")
                    expect(okLocalizedTitle).toEventually(equal("Ok_title"), timeout: .seconds(10))
                }

                it("will return the key as string") {
                    let cancelLocalizedTitle = "Cancel_title".localizedString(path: "")
                    expect(cancelLocalizedTitle).toEventually(equal("Cancel_title"), timeout: .seconds(10))
                }
            }
            context("when calling hasHTTPPrefix with a valid http string") {
                it("will return true for http string") {
                    expect("http://miniapp".hasHTTPPrefix).to(beTrue())
                }
                it("will return true for https string") {
                    expect("https://miniapp".hasHTTPPrefix).to(beTrue())
                }
                it("will return true for http string (case insensitive)") {
                    expect("hTTp://miniapp".hasHTTPPrefix).to(beTrue())
                }
                it("will return false for http string with white character at the beginning") {
                    expect(" http://miniapp".hasHTTPPrefix).to(beFalse())
                }
            }
            context("when calling hasHTTPPrefix with an invalid http string") {
                it("will return false incomplete http url") {
                    expect("http:/miniapp".hasHTTPPrefix).to(beFalse())
                    expect("http//miniapp".hasHTTPPrefix).to(beFalse())
                }
                it("will return false for other url schemes") {
                    expect("file://file".hasHTTPPrefix).to(beFalse())
                }
                it("will return false for empty string") {
                    expect("".hasHTTPPrefix).to(beFalse())
                }
                it("will return false for string containing only white characters") {
                    expect(" ".hasHTTPPrefix).to(beFalse())
                }
                it("will return false for non url string") {
                    expect("a1".hasHTTPPrefix).to(beFalse())
                }
            }
        }
    }
}
