import Foundation
import Quick
import Nimble
@testable import MiniApp

class MiniAppViewControllerTests: QuickSpec {

    override func spec() {
        describe("show mini app vc") {

            var mockMessageInterface: MockMessageInterface!

            beforeEach {
                mockMessageInterface = MockMessageInterface()
            }

            context("when config is passed") {
                it("will show miniapp view") {
                    let miniAppVc = MiniAppViewController(title: "MiniAppTest", appId: self.mockAppId, config: self.mockConfig, messageDelegate: mockMessageInterface)
                    miniAppVc.setupMiniApp()
                    expect(miniAppVc.state).to(equal(MiniAppViewController.ViewState.loading))
                    expect(miniAppVc.fallbackView.isHidden).to(beTrue())
                    expect(miniAppVc.state).toEventually(equal(MiniAppViewController.ViewState.success), timeout: .seconds(self.timeoutDelaySeconds))
                    expect(miniAppVc.fallbackView.isHidden).toEventually(beTrue(), timeout: .seconds(self.timeoutDelaySeconds))
                    expect(miniAppVc.view.subviews.last).to(beAnInstanceOf(RealMiniAppView.self))
                }

                it("retry button is pressed with valid config") {
                    let miniAppVc = MiniAppViewController(title: "MiniAppTest", appId: self.mockAppId, config: self.emptyConfig, messageDelegate: mockMessageInterface)
                    miniAppVc.setupMiniApp()
                    miniAppVc.setup()
                    expect(miniAppVc.state).to(equal(MiniAppViewController.ViewState.loading))
                    expect(miniAppVc.state).toEventually(equal(MiniAppViewController.ViewState.error), timeout: .seconds(self.timeoutDelaySeconds))

                    miniAppVc.config = self.mockConfig
                    miniAppVc.fallbackView.onRetry?()
                    expect(miniAppVc.state).to(equal(MiniAppViewController.ViewState.loading))
                    expect(miniAppVc.state).toEventually(equal(MiniAppViewController.ViewState.success), timeout: .seconds(self.timeoutDelaySeconds))
                }
            }

            context("when no config is passed") {
                it("will show fallback") {
                    let miniAppVc = MiniAppViewController(title: "MiniAppTest", appId: self.mockAppId, config: self.emptyConfig, messageDelegate: mockMessageInterface)
                    miniAppVc.setupMiniApp()
                    expect(miniAppVc.state).to(equal(MiniAppViewController.ViewState.loading))
                    expect(miniAppVc.fallbackView.isHidden).to(beTrue())
                    expect(miniAppVc.state).toEventually(equal(MiniAppViewController.ViewState.error), timeout: .seconds(self.timeoutDelaySeconds))
                    expect(miniAppVc.fallbackView.isHidden).toEventually(beFalse(), timeout: .seconds(self.timeoutDelaySeconds))
                }

                it("retry button is pressed with invalid config") {
                    let miniAppVc = MiniAppViewController(title: "MiniAppTest", appId: self.mockAppId, config: self.emptyConfig, messageDelegate: mockMessageInterface)
                    miniAppVc.setupMiniApp()
                    miniAppVc.setup()
                    expect(miniAppVc.state).to(equal(MiniAppViewController.ViewState.loading))
                    expect(miniAppVc.state).toEventually(equal(MiniAppViewController.ViewState.error), timeout: .seconds(self.timeoutDelaySeconds))

                    miniAppVc.fallbackView.onRetry?()
                    expect(miniAppVc.state).to(equal(MiniAppViewController.ViewState.loading))
                    expect(miniAppVc.state).toEventually(equal(MiniAppViewController.ViewState.error), timeout: .seconds(self.timeoutDelaySeconds))
                }
            }

        }
    }
    
    var timeoutDelaySeconds: Int = 2

    var mockAppId: String {
        ""
    }

    var mockConfig: MiniAppSdkConfig {
        MiniAppSdkConfig()
    }

    var emptyConfig: MiniAppSdkConfig {
        MiniAppSdkConfig(
            baseUrl: "",
            rasProjectId: "",
            subscriptionKey: "",
            isPreviewMode: false
        )
    }
}
