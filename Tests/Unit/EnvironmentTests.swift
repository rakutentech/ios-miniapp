import Quick
import Nimble
@testable import MiniApp

// swiftlint:disable function_body_length
class EnvironmentTests: QuickSpec {
    override func spec() {
        context("when bundle has valid key-values") {
            it("uses the main bundle when no bundle parameter is supplied") {
                let environment = Environment()
                let bundle = environment.bundle as? Bundle ?? Bundle(for: EnvironmentTests.self)

                expect(bundle).to(equal(Bundle.main))
                expect(bundle.valueNotFound).to(equal("NONE"))
            }
            it("has the expected project id") {
                let mockBundle = MockBundle()
                mockBundle.mockProjectId = "1.1"

                let environment = Environment(bundle: mockBundle)

                expect(environment.projectId).to(equal("1.1"))
            }
            it("has the expected subscription key") {
                let mockBundle = MockBundle()
                mockBundle.mockSubscriptionKey = "mini-subscription-key"

                let environment = Environment(bundle: mockBundle)

                expect(environment.subscriptionKey).to(contain("mini-subscription-key"))
            }
            it("will return base url endpoint") {
                let mockBundle = MockBundle()
                mockBundle.mockEndpoint = mockHost
                let environment = Environment(bundle: mockBundle)

                expect(environment.baseUrl?.absoluteString).to(equal(mockHost))
            }
            it("will return host app info") {
                let mockBundle = MockBundle()
                mockBundle.mockHostAppUserAgentInfo = "Demo app v1.1"
                let environment = Environment(bundle: mockBundle)

                expect(environment.hostAppUserAgentInfo).to(equal("Demo app v1.1"))
            }
            it("will return preview mode if it is provided") {
                let mockBundle = MockBundle()
                mockBundle.mockPreviewMode = false
                let environment = Environment(bundle: mockBundle)

                expect(environment.isPreviewMode).to(equal(false))
            }
        }
        context("when bundle does not have valid key values") {
            let mockBundle = MockBundle()
            mockBundle.mockProjectId = nil
            mockBundle.mockSubscriptionKey = nil
            mockBundle.mockEndpoint = nil
            mockBundle.mockAppVersion = nil
            mockBundle.mockHostAppUserAgentInfo = nil
            mockBundle.mockValueNotFound = "Value Not Found"
            let environment = Environment(bundle: mockBundle)
            it("will return app id as nil") {
                expect(environment.projectId).to(equal(mockBundle.valueNotFound))
            }
            it("will return subscription key as nil") {
                expect(environment.subscriptionKey).to(equal(mockBundle.valueNotFound))
            }
            it("will return endpoint as nil") {
                expect(environment.baseUrl?.absoluteString).to(beNil())
            }
            it("will return app version as nil") {
                expect(environment.appVersion).to(equal(mockBundle.valueNotFound))
            }
            it("will return ssl pins as nil") {
                expect(environment.sslKeyHash).to(beNil())
                expect(environment.sslKeyHashBackup).to(beNil())
            }
            it("will return host app info value not found") {
                expect(environment.hostAppUserAgentInfo).to(equal(mockBundle.valueNotFound))
            }
        }
    }
}
