import Quick
import Nimble
@testable import MiniApp

// swiftlint:disable function_body_length
class MiniAppSdkConfigTests: QuickSpec {
    override func spec() {
        describe("MiniAppSdkConfig") {
            context("when MiniAppSdkConfig is initialized with valid parameters") {
                it("will return all values") {
                    let config = MiniAppSdkConfig(baseUrl: "http://example.com", rasProjectId: "mini-app-project-id",
                                                  subscriptionKey: "mini-app-sub-key", hostAppVersion: "1.0", isPreviewMode: false,
                                                  analyticsConfigList: [MAAnalyticsConfig(acc: mockRATAcc, aid: mockRATAid)],
                                                  requireMiniAppSignatureVerification: true)
                    let env = Environment(with: config)
                    expect(config.baseUrl).to(equal("http://example.com"))
                    expect(config.rasProjectId).to(equal("mini-app-project-id"))
                    expect(config.subscriptionKey).to(equal("mini-app-sub-key"))
                    expect(config.hostAppVersion).to(equal("1.0"))
                    expect(config.isPreviewMode).to(be(false))
                    expect(config.analyticsConfigList).notTo(be(nil))
                    expect(config.analyticsConfigList?[0].acc).to(be(mockRATAcc))
                    expect(config.analyticsConfigList?[0].aid).to(be(mockRATAid))
                    expect(config.requireMiniAppSignatureVerification).to(be(true))
                    expect(env.baseUrl?.absoluteString).to(equal(config.baseUrl))
                    expect(env.projectId).to(equal(config.rasProjectId))
                    expect(env.subscriptionKey).to(equal(config.subscriptionKey))
                    expect(env.appVersion).to(equal(config.hostAppVersion))
                    expect(env.isPreviewMode).to(be(config.isPreviewMode))
                    expect(env.requireMiniAppSignatureVerification).to(be(config.requireMiniAppSignatureVerification))
                }
            }
            context("when MiniAppSdkConfig is initialized with default constructor") {
                it("environment will return default values") {
                    let config = Environment(with: MiniAppSdkConfig())
                    expect(config.customUrl).to(beNil())
                    expect(config.customProjectId).to(beNil())
                    expect(config.customAppVersion).to(beNil())
                    expect(config.customSubscriptionKey).to(beNil())
                    expect(config.customIsPreviewMode).to(beNil())
                    expect(config.customSignatureVerification).to(beNil())
                    expect(config.baseUrl).toNot(beNil())
                    expect(config.projectId).toNot(beNil())
                    expect(config.subscriptionKey).toNot(beNil())
                    expect(config.appVersion).toNot(beNil())
                    expect(config.isPreviewMode).to(be(true))
                    expect(config.requireMiniAppSignatureVerification).to(be(false))
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
                    config.requireMiniAppSignatureVerification = true
                    config.analyticsConfigList = [MAAnalyticsConfig(acc: mockRATAcc, aid: mockRATAid)]
                    let env = Environment(with: config)

                    expect(config.baseUrl).to(equal("http://example.com"))
                    expect(config.rasProjectId).to(equal("mini-app-host-id"))
                    expect(config.subscriptionKey).to(equal("mini-app-sub-key"))
                    expect(config.hostAppVersion).to(equal("1.0"))
                    expect(config.isPreviewMode).to(be(false))
                    expect(config.analyticsConfigList).notTo(be(nil))
                    expect(config.analyticsConfigList?[0].acc).to(be(mockRATAcc))
                    expect(config.analyticsConfigList?[0].aid).to(be(mockRATAid))
                    expect(config.requireMiniAppSignatureVerification).to(be(true))
                    expect(env.baseUrl?.absoluteString).to(equal(config.baseUrl))
                    expect(env.projectId).to(equal(config.rasProjectId))
                    expect(env.subscriptionKey).to(equal(config.subscriptionKey))
                    expect(env.appVersion).to(equal(config.hostAppVersion))
                    expect(env.isPreviewMode).to(be(config.isPreviewMode))
                    expect(env.requireMiniAppSignatureVerification).to(be(config.requireMiniAppSignatureVerification))
                }
            }
        }
    }
}
