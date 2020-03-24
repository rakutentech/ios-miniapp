import Quick
import Nimble
@testable import MiniApp

class RealMiniAppViewTests: QuickSpec {

    override func spec() {
        describe("Mini App view") {
            context("when initialized with valid parameters") {
                it("will return MiniAppView object") {
                    let realMiniAppView = RealMiniAppView.shared.getMiniAppView(miniAppId: "mini-app-testing")
                    expect(realMiniAppView).toEventually(beAnInstanceOf(MiniAppView.self))
                }
            }
        }
    }
}
