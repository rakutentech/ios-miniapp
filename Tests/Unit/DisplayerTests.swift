import Quick
import Nimble
@testable import MiniApp

class DisplayerTests: QuickSpec {

    override func spec() {
        describe("get mini app view") {

            var miniAppDisplayer: Displayer!
            var mockMessageInterface: MockMessageInterface!

            beforeEach {
                miniAppDisplayer = Displayer()
                mockMessageInterface = MockMessageInterface()
            }

            context("when mini app id is passed") {
                it("will return MiniAppView") {
                    let miniAppView = miniAppDisplayer.getMiniAppView(miniAppId: "miniappid-testing",
                                                                      versionId: "version-id",
                                                                      miniAppTitle: "Mini app title",
                                                                      hostAppMessageDelegate: mockMessageInterface)
                    expect(miniAppView).toEventually(beAnInstanceOf(RealMiniAppView.self), timeout: .seconds(10))
                }
            }

            context("when mini app url is passed") {
                it("will return MiniAppView for valid url") {
                    let miniAppView = miniAppDisplayer.getMiniAppView(miniAppURL: URL(string: "http://miniapp")!,
                                                                      miniAppTitle: "Mini app title",
                                                                      hostAppMessageDelegate: mockMessageInterface,
                                                                      initialLoadCallback: { _ in })
                    expect(miniAppView).toEventually(beAnInstanceOf(RealMiniAppView.self), timeout: .seconds(10))
                }
                it("will return MiniAppView for invalid url") {
                    let miniAppView = miniAppDisplayer.getMiniAppView(miniAppURL: URL(string: "file:/miniapp")!,
                                                                      miniAppTitle: "Mini app title",
                                                                      hostAppMessageDelegate: mockMessageInterface,
                                                                      initialLoadCallback: { _ in })
                    expect(miniAppView).toEventually(beAnInstanceOf(RealMiniAppView.self), timeout: .seconds(10))
                }
            }
        }
    }
}
