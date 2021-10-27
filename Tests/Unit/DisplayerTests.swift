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
                    let miniAppView = miniAppDisplayer.getMiniAppView(miniAppId: mockMiniAppInfo.id,
                                                                      versionId: mockMiniAppInfo.version.versionId,
                                                                      projectId: "project-id",
                                                                      miniAppTitle: mockMiniAppInfo.displayName!,
                                                                      hostAppMessageDelegate: mockMessageInterface)
                    expect(miniAppView).to(beAnInstanceOf(RealMiniAppView.self))
                }
            }

            context("when mini app url is passed") {
                it("will return MiniAppView for valid url") {
                    let miniAppView = miniAppDisplayer.getMiniAppView(miniAppURL: URL(string: "http://miniapp")!,
                                                                      miniAppTitle: mockMiniAppInfo.displayName!,
                                                                      hostAppMessageDelegate: mockMessageInterface,
                                                                      initialLoadCallback: { _ in })
                    expect(miniAppView).to(beAnInstanceOf(RealMiniAppView.self))
                }
                it("will return MiniAppView for invalid url") {
                    let miniAppView = miniAppDisplayer.getMiniAppView(miniAppURL: URL(string: "file:/miniapp")!,
                                                                      miniAppTitle: mockMiniAppInfo.displayName!,
                                                                      hostAppMessageDelegate: mockMessageInterface,
                                                                      initialLoadCallback: { _ in })
                    expect(miniAppView).to(beAnInstanceOf(RealMiniAppView.self))
                }
            }
        }
    }
}
