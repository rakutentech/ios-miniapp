import Quick
import Nimble
@testable import MiniApp

// swiftlint:disable function_body_length
class MiniAppSdkConfigTests: QuickSpec {
    override func spec() {
        describe("MiniAppSdkConfig") {
            context("when hostAppUserAgentInfo is initialized with valid parameters") {
                it("will return all values") {
                    let config = MiniAppSdkConfig(baseUrl: "http://example.com",
                                                  rasAppId: "mini-app-host-id",
                                                  subscriptionKey: "mini-app-sub-key",
                                                  hostAppVersion: "1.0",
                                                  isTestMode: true,
                                                  hostAppUserAgentInfo: "Demo app v1")
                    expect(config.baseUrl).to(equal("http://example.com"))
                    expect(config.rasAppId).to(equal("mini-app-host-id"))
                    expect(config.subscriptionKey).to(equal("mini-app-sub-key"))
                    expect(config.hostAppVersion).to(equal("1.0"))
                    expect(config.isTestMode).to(be(true))
                    expect(config.hostAppUserAgentInfo).to(equal("Demo app v1"))
                }
            }
            context("when hostAppUserAgentInfo is initialized with default constructor") {
                it("will return nil values") {
                    let config = MiniAppSdkConfig()
                    expect(config.baseUrl).to(beNil())
                    expect(config.rasAppId).to(beNil())
                    expect(config.subscriptionKey).to(beNil())
                    expect(config.hostAppVersion).to(beNil())
                    expect(config.isTestMode).to(be(false))
                    expect(config.hostAppUserAgentInfo).to(beNil())
                }
            }
            context("when hostAppUserAgentInfo is initialized with default constructor and value is set") {
                it("will return all values") {
                    let config = MiniAppSdkConfig()
                    config.baseUrl = "http://example.com"
                    config.rasAppId = "mini-app-host-id"
                    config.subscriptionKey = "mini-app-sub-key"
                    config.hostAppVersion = "1.0"
                    config.isTestMode = true
                    config.hostAppUserAgentInfo = "Demo app v1.0"
                    expect(config.baseUrl).to(equal("http://example.com"))
                    expect(config.rasAppId).to(equal("mini-app-host-id"))
                    expect(config.subscriptionKey).to(equal("mini-app-sub-key"))
                    expect(config.hostAppVersion).to(equal("1.0"))
                    expect(config.isTestMode).to(be(true))
                    expect(config.hostAppUserAgentInfo).to(equal("Demo app v1.0"))
                    config.hostAppUserAgentInfo = ""
                    expect(config.hostAppUserAgentInfo).to(equal(""))
                }
            }
        }
    }
}
