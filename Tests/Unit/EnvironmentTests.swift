import Quick
import Nimble
@testable import MiniApp

// swiftlint:disable function_body_length
class EnvironmentTests: QuickSpec {
    override func spec() {
        it("uses the main bundle when no bundle parameter is supplied") {
            let environment = Environment()
            let bundle = environment.bundle as? Bundle ?? Bundle(for: EnvironmentTests.self)

            expect(bundle).to(equal(Bundle.main))
        }
        context("when bundle has valid key-values") {
            it("has the expected app id") {
                let mockBundle = MockBundle()
                mockBundle.mockAppId = "1.1"

                let environment = Environment(bundle: mockBundle)

                expect(environment.appId).to(equal("1.1"))
            }
            it("has the expected app version") {
                let mockBundle = MockBundle()
                mockBundle.mockAppVersion = "mini"

                let environment = Environment(bundle: mockBundle)

                expect(environment.appVersion).to(equal("mini"))
            }
            it("has the expected subscription key") {
                let mockBundle = MockBundle()
                mockBundle.mockSubscriptionKey = "mini-subscription-key"

                let environment = Environment(bundle: mockBundle)

                expect(environment.subscriptionKey).to(contain("mini-subscription-key"))
            }
            it("will return base url endpoint") {
                let mockBundle = MockBundle()
                mockBundle.mockEndpoint = "https://example-endpoint.com"
                let environment = Environment(bundle: mockBundle)

                expect(environment.baseUrl?.absoluteString).to(equal("https://example-endpoint.com"))
            }
        }
        context("when bundle does not have valid key values") {
            let mockBundle = MockBundle()
            mockBundle.mockAppId = nil
            mockBundle.mockSubscriptionKey = nil
            mockBundle.mockEndpoint = nil
            mockBundle.mockAppVersion = nil
            mockBundle.mockValueNotFound = "Value Not Found"
            let environment = Environment(bundle: mockBundle)
            it("will return app id as nil") {
                expect(environment.appId).to(equal(mockBundle.valueNotFound))
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
        }
    }
}
