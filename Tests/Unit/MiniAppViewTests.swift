import Quick
import Nimble
@testable import MiniApp

class MiniAppViewTests: QuickSpec {

    override func spec() {
        describe("Mini App view") {
            let mockMessageInterface = MockMessageInterface()
            context("when initialized with valid parameters") {
                it("will return MiniAppView object") {
                    let miniAppView = MiniAppView(miniAppId: "miniappid-testing", messageInterface: mockMessageInterface)
                    expect(miniAppView).toEventually(beAnInstanceOf(MiniAppView.self))
                }
            }
            context("when getMiniAppView is called") {
                it("will return object of UIView type") {
                    let miniAppView = MiniAppView(miniAppId: "miniappid-testing", messageInterface: mockMessageInterface)
                    expect(miniAppView?.getMiniAppView()).toEventually(beAKindOf(UIView.self))
                }
            }
        }
    }
}
