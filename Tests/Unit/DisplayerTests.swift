import Quick
import Nimble
@testable import MiniApp

class DisplayerTests: QuickSpec {

    override func spec() {
        describe("get mini app view") {
            context("when mini app id is passed") {
                it("will return MiniAppView") {
                    let miniAppDisplayer = Displayer()
                    let miniAppView = miniAppDisplayer.getMiniAppView(miniAppId: "miniappid-testing")
                    expect(miniAppView).toEventually(beAnInstanceOf(MiniAppView.self))
                }
            }
        }
    }
}
