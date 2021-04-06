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
                    expect(miniAppVc.state == .loading).to(beTrue())
                    expect(miniAppVc.fallbackView.isHidden).to(beTrue())
                    expect(miniAppVc.state == .success).toEventually(beTrue(), timeout: .seconds(1))
                    expect(miniAppVc.fallbackView.isHidden).toEventually(beTrue(), timeout: .seconds(1))
                    expect(miniAppVc.view.subviews.last).to(beAnInstanceOf(RealMiniAppView.self))
                }

                it("retry button is pressed with valid config") {
                    let miniAppVc = MiniAppViewController(title: "MiniAppTest", appId: self.mockAppId, config: self.emptyConfig, messageDelegate: mockMessageInterface)
                    miniAppVc.setupMiniApp()
                    miniAppVc.setup()
                    expect(miniAppVc.state == .loading).to(beTrue())
                    expect(miniAppVc.state == .error).toEventually(beTrue(), timeout: .seconds(1))

                    miniAppVc.config = self.mockConfig
                    miniAppVc.fallbackView.onRetry?()
                    expect(miniAppVc.state == .loading).to(beTrue())
                    expect(miniAppVc.state == .success).toEventually(beTrue(), timeout: .seconds(1))
                }
            }

            context("when no config is passed") {
                it("will show fallback") {
                    let miniAppVc = MiniAppViewController(title: "MiniAppTest", appId: self.mockAppId, config: self.emptyConfig, messageDelegate: mockMessageInterface)
                    miniAppVc.setupMiniApp()
                    expect(miniAppVc.state == .loading).to(beTrue())
                    expect(miniAppVc.fallbackView.isHidden).to(beTrue())
                    expect(miniAppVc.state == .error).toEventually(beTrue(), timeout: .seconds(1))
                    expect(miniAppVc.fallbackView.isHidden).toEventually(beFalse(), timeout: .seconds(1))
                }

                it("retry button is pressed with invalid config") {
                    let miniAppVc = MiniAppViewController(title: "MiniAppTest", appId: self.mockAppId, config: self.emptyConfig, messageDelegate: mockMessageInterface)
                    miniAppVc.setupMiniApp()
                    miniAppVc.setup()
                    expect(miniAppVc.state == .loading).to(beTrue())
                    expect(miniAppVc.state == .error).toEventually(beTrue(), timeout: .seconds(1))

                    miniAppVc.fallbackView.onRetry?()
                    expect(miniAppVc.state == .loading).to(beTrue())
                    expect(miniAppVc.state == .error).toEventually(beTrue(), timeout: .seconds(1))
                }
            }

        }
    }

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
