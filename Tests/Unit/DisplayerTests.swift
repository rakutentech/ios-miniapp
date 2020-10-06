import Quick
import Nimble
@testable import MiniApp

class DisplayerTests: QuickSpec {

    override func spec() {
        describe("get mini app view") {
            context("when mini app id is passed") {
                it("will return MiniAppView") {
                    let miniAppDisplayer = Displayer()
                    let mockMessageInterface = MockMessageInterface()
                    let mockUserInfoInterface = MockUserInfoInterface()
                    let miniAppView = miniAppDisplayer.getMiniAppView(miniAppId: "miniappid-testing",
                                                                      versionId: "version-id",
                                                                      miniAppTitle: "Mini app title",
                                                                      hostAppMessageDelegate: mockMessageInterface, hostAppUserInfoProtocol: mockUserInfoInterface)
                    expect(miniAppView).toEventually(beAnInstanceOf(RealMiniAppView.self), timeout: 10)
                }
            }
        }
    }
}
