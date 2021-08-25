import Quick
import Nimble
@testable import MiniApp

class MiniAppSdkConfigTests: QuickSpec {
    override func spec() {
        describe("MiniAppSdkConfig") {
            context("when MiniAppSdkConfig is initialized with valid parameters") {
                it("will return all values") {
                    let config = MiniAppSdkConfig(baseUrl: "http://example.com", rasProjectId: "mini-app-project-id",
                                                  subscriptionKey: "mini-app-sub-key", hostAppVersion: "1.0", isPreviewMode: false,
                                                  analyticsConfigList: [MAAnalyticsConfig(acc: mockRATAcc, aid: mockRATAid)])
                    expect(config.baseUrl).to(equal("http://example.com"))
                    expect(config.rasProjectId).to(equal("mini-app-project-id"))
                    expect(config.subscriptionKey).to(equal("mini-app-sub-key"))
                    expect(config.hostAppVersion).to(equal("1.0"))
                    expect(config.isPreviewMode).to(be(false))
                    expect(config.analyticsConfigList).notTo(be(nil))
                    expect(config.analyticsConfigList?[0].acc).to(be(mockRATAcc))
                    expect(config.analyticsConfigList?[0].aid).to(be(mockRATAid))
                }
            }
            context("when MiniAppSdkConfig is initialized with default constructor") {
                it("will return nil values") {
                    let config = MiniAppSdkConfig()
                    expect(config.baseUrl).to(beNil())
                    expect(config.rasProjectId).to(beNil())
                    expect(config.subscriptionKey).to(beNil())
                    expect(config.hostAppVersion).to(beNil())
                    expect(config.isPreviewMode).to(be(false))
                    expect(config.analyticsConfigList?.count).to(be(0))
                }
            }
            context("when MiniAppSdkConfig is initialized with default constructor and value is set later") {
                it("will return all values") {
                    let config = MiniAppSdkConfig()
                    config.baseUrl = "http://example.com"
                    config.rasProjectId = "mini-app-host-id"
                    config.subscriptionKey = "mini-app-sub-key"
                    config.hostAppVersion = "1.0"
                    config.isPreviewMode = false
                    config.analyticsConfigList = [MAAnalyticsConfig(acc: mockRATAcc, aid: mockRATAid)]
                    expect(config.baseUrl).to(equal("http://example.com"))
                    expect(config.rasProjectId).to(equal("mini-app-host-id"))
                    expect(config.subscriptionKey).to(equal("mini-app-sub-key"))
                    expect(config.hostAppVersion).to(equal("1.0"))
                    expect(config.isPreviewMode).to(be(false))
                    expect(config.analyticsConfigList).notTo(be(nil))
                    expect(config.analyticsConfigList?[0].acc).to(be(mockRATAcc))
                    expect(config.analyticsConfigList?[0].aid).to(be(mockRATAid))
                }
            }
        }
    }
}
