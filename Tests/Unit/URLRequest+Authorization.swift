import Quick
import Nimble
@testable import MiniApp

class URLRequest_HeadersTests: QuickSpec {

    override func spec() {
        describe("authorization header is set") {
            context("when setAuthorizationHeader is called") {
                it("will get subscription key from bundle") {
                    let mockBundle = MockBundle()
                    mockBundle.mockSubscriptionKey = "MINIAPP_SUBSCRIPTION_KEY"
                    var urlRequest = URLRequest(url: URL(string: "https://www.example.com")!)
                    urlRequest.setAuthorizationHeader(environment: Environment(bundle: mockBundle))
                    expect(urlRequest.value(forHTTPHeaderField: "Authorization")).toEventually(equal("MINIAPP_SUBSCRIPTION_KEY"))
                }
            }
        }
        describe("authorization header is not set") {
            context("when setAuthorizationHeader is called with no subscription key") {
                it("will not add subscription key for urlrequest") {
                    let mockBundle = MockBundle()
                    mockBundle.mockSubscriptionKey = ""
                    var urlRequest = URLRequest(url: URL(string: "https://www.example.com")!)
                    urlRequest.setAuthorizationHeader(environment: Environment(bundle: mockBundle))
                    expect(urlRequest.value(forHTTPHeaderField: "Authorization")).toEventually(beNil())
                }
            }
        }
    }
}
