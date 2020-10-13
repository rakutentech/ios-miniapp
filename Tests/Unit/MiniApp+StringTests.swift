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
            }
            context("when localized key is passed that is available in Pod bundle") {
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
            }
            context("when localized key is passed with pod bundle path as empty") {
                it("will return the key as string") {
                    let cancelLocalizedTitle = "Cancel_title".localizedString(path: "")
                    expect(cancelLocalizedTitle).toEventually(equal("Cancel_title"), timeout: .seconds(10))
                }
            }
        }
    }
}
