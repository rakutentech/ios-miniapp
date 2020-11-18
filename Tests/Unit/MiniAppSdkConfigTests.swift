import Quick
import Nimble
@testable import MiniApp

class MiniAppSdkConfigTests: QuickSpec {
    override func spec() {
        describe("MiniAppSdkConfig") {
            context("when MiniAppSdkConfig is initialized with valid parameters") {
                it("will return all values") {
                    let config = MiniAppSdkConfig(baseUrl: "http://example.com",
                                                  rasAppId: "mini-app-host-id",
                                                  subscriptionKey: "mini-app-sub-key",
                                                  hostAppVersion: "1.0",
                                                  isTestMode: false)
                    expect(config.baseUrl).to(equal("http://example.com"))
                    expect(config.rasAppId).to(equal("mini-app-host-id"))
                    expect(config.subscriptionKey).to(equal("mini-app-sub-key"))
                    expect(config.hostAppVersion).to(equal("1.0"))
                    expect(config.isPreviewMode).to(be(false))
                }
            }
            context("when MiniAppSdkConfig is initialized with default constructor") {
                it("will return nil values") {
                    let config = MiniAppSdkConfig()
                    expect(config.baseUrl).to(beNil())
                    expect(config.rasAppId).to(beNil())
                    expect(config.subscriptionKey).to(beNil())
                    expect(config.hostAppVersion).to(beNil())
                    expect(config.isPreviewMode).to(be(true))
                }
            }
            context("when MiniAppSdkConfig is initialized with default constructor and value is set") {
                it("will return all values") {
                    let config = MiniAppSdkConfig()
                    config.baseUrl = "http://example.com"
                    config.rasAppId = "mini-app-host-id"
                    config.subscriptionKey = "mini-app-sub-key"
                    config.hostAppVersion = "1.0"
                    config.isPreviewMode = false
                    expect(config.baseUrl).to(equal("http://example.com"))
                    expect(config.rasAppId).to(equal("mini-app-host-id"))
                    expect(config.subscriptionKey).to(equal("mini-app-sub-key"))
                    expect(config.hostAppVersion).to(equal("1.0"))
                    expect(config.isPreviewMode).to(be(false))
                }
            }
        }
    }
}
