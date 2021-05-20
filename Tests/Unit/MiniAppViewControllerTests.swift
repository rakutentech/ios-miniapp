import Foundation
import Quick
import Nimble
@testable import MiniApp

class MiniAppViewControllerTests: QuickSpec {

    class MockMiniAppViewController: MiniAppViewController {
        var resultState: ViewState = .success
        override func setupMiniApp() {
            state = .loading
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                DispatchQueue.main.async {
                    self.state = self.resultState
                }
            })
        }
    }

    override func spec() {
        describe("show mini app vc") {

            var mockMessageInterface: MockMessageInterface!

            beforeEach {
                mockMessageInterface = MockMessageInterface()
            }

            context("using mock miniappvc") {
                it("will show miniapp view") {
                    let miniAppVc = MockMiniAppViewController(title: "MiniAppTest", appId: self.mockAppId, config: self.mockConfig, messageDelegate: mockMessageInterface)
                    miniAppVc.setupMiniApp()
                    expect(miniAppVc.state).to(equal(MiniAppViewController.ViewState.loading))
                    expect(miniAppVc.fallbackView.isHidden).to(beTrue())
                    expect(miniAppVc.state).toEventually(equal(MiniAppViewController.ViewState.success), timeout: .seconds(self.timeoutDelaySeconds))
                }

                it("retry button is pressed with valid config") {
                    let miniAppVc = MockMiniAppViewController(title: "MiniAppTest", appId: self.mockAppId, config: self.emptyConfig, messageDelegate: mockMessageInterface)
                    miniAppVc.setupMiniApp()
                    miniAppVc.setupFallback()
                    miniAppVc.resultState = .error
                    expect(miniAppVc.state).to(equal(MiniAppViewController.ViewState.loading))
                    expect(miniAppVc.state).toEventually(equal(MiniAppViewController.ViewState.error), timeout: .seconds(self.timeoutDelaySeconds))

                    miniAppVc.config = self.mockConfig
                    miniAppVc.resultState = .success
                    miniAppVc.fallbackView.onRetry?()
                    expect(miniAppVc.state).to(equal(MiniAppViewController.ViewState.loading))
                    expect(miniAppVc.state).toEventually(equal(MiniAppViewController.ViewState.success), timeout: .seconds(self.timeoutDelaySeconds))
                }
            }

            context("when empty config is passed") {
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
                    miniAppVc.setupFallback()
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
