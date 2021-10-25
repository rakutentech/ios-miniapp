import Quick
import Nimble
@testable import MiniApp

// swiftlint:disable function_body_length
class MiniAppSdkConfigTests: QuickSpec {
    override func spec() {
        describe("MiniAppSdkConfig") {
            context("when MiniAppSdkConfig is initialized with valid parameters") {
                it("will return all values") {
                    let config = MiniAppSdkConfig(baseUrl: mockHost, rasProjectId: "mini-app-project-id",
                                                  subscriptionKey: "mini-app-sub-key", hostAppVersion: "1.0", isPreviewMode: false,
                                                  analyticsConfigList: [MAAnalyticsConfig(acc: mockRATAcc, aid: mockRATAid)],
                                                  requireMiniAppSignatureVerification: true)
                    let env = Environment(with: config)
                    expect(config.baseUrl).to(equal(mockHost))
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
                    expect(config.customSSLKeyHash).to(beNil())
                    expect(config.customSSLKeyHashBackup).to(beNil())
                    expect(config.customSignatureVerification).to(beNil())
                    expect(config.baseUrl).toNot(beNil())
                    expect(config.projectId).toNot(beNil())
                    expect(config.subscriptionKey).toNot(beNil())
                    expect(config.appVersion).toNot(beNil())
                    expect(config.isPreviewMode).to(be(true))
                    expect(config.sslKeyHash).to(beNil())
                    expect(config.sslKeyHashBackup).to(beNil())
                    expect(config.requireMiniAppSignatureVerification).to(be(false))
                }
            }
            context("when MiniAppSdkConfig is initialized with default constructor and value is set later") {
                it("will return all values") {
                    let pinConf = MiniAppConfigSSLKeyHash(pin: "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=", backup: "AABBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=")
                    let config = MiniAppSdkConfig()
                    config.baseUrl = mockHost
                    config.rasProjectId = "mini-app-host-id"
                    config.subscriptionKey = "mini-app-sub-key"
                    config.hostAppVersion = "1.0"
                    config.isPreviewMode = false
                    config.requireMiniAppSignatureVerification = true
                    config.analyticsConfigList = [MAAnalyticsConfig(acc: mockRATAcc, aid: mockRATAid)]
                    config.sslKeyHash = pinConf
                    let env = Environment(with: config)

                    expect(config.baseUrl).to(equal(mockHost))
                    expect(config.rasProjectId).to(equal("mini-app-host-id"))
                    expect(config.subscriptionKey).to(equal("mini-app-sub-key"))
                    expect(config.hostAppVersion).to(equal("1.0"))
                    expect(config.isPreviewMode).to(be(false))
                    expect(config.analyticsConfigList).notTo(be(nil))
                    expect(config.analyticsConfigList?[0].acc).to(be(mockRATAcc))
                    expect(config.analyticsConfigList?[0].aid).to(be(mockRATAid))
                    expect(config.requireMiniAppSignatureVerification).to(be(true))
                    expect(config.sslKeyHash?.pin).to(equal("BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB="))
                    expect(config.sslKeyHash?.backupPin).to(equal("AABBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB="))
                    expect(env.baseUrl?.absoluteString).to(equal(config.baseUrl))
                    expect(env.projectId).to(equal(config.rasProjectId))
                    expect(env.subscriptionKey).to(equal(config.subscriptionKey))
                    expect(env.appVersion).to(equal(config.hostAppVersion))
                    expect(env.isPreviewMode).to(be(config.isPreviewMode))
                    expect(env.requireMiniAppSignatureVerification).to(be(config.requireMiniAppSignatureVerification))
                    expect(env.sslKeyHash).to(equal(config.sslKeyHash?.pin))
                    expect(env.sslKeyHashBackup).to(equal(config.sslKeyHash?.backupPin))
                }
            }
        }
    }
}
