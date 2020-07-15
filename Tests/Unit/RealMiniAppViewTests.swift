import Quick
import Nimble
@testable import MiniApp

class RealMiniAppViewTests: QuickSpec {

    override func spec() {
        describe("Mini App view") {
            let mockMessageInterface = MockMessageInterface()
            context("when initialized with valid parameters") {
                it("will return MiniAppView object") {
                    let miniAppView = RealMiniAppView(miniAppId: "miniappid-testing", versionId: "version-id", hostAppMessageDelegate: mockMessageInterface)

                    expect(miniAppView).toEventually(beAnInstanceOf(RealMiniAppView.self))
                }
            }
            context("when getMiniAppView is called") {
                it("will return object of UIView type") {
                    let miniAppView = RealMiniAppView(miniAppId: "miniappid-testing", versionId: "version-id", hostAppMessageDelegate: mockMessageInterface)
                    expect(miniAppView.getMiniAppView()).toEventually(beAKindOf(UIView.self))
                }
            }
            context("when host app info is specified in plist") {
                it("will add custom string in User agent") {
                    let miniAppView = RealMiniAppView(miniAppId: "miniappid-testing", versionId: "version-id", hostAppMessageDelegate: mockMessageInterface)
                    expect(miniAppView.webView.customUserAgent).toEventually(contain("HOSTAPPNAME_AND_VERSION"), timeout: 3)

                }
            }
        }
    }
}
