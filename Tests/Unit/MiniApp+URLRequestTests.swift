import Quick
import Nimble
@testable import MiniApp

class MiniAppURLRequestTests: QuickSpec {

    override func spec() {
        describe("create url request") {
            guard let url = URL(string: "http://example.com") else {
                return
            }
            let mockBundle = MockBundle()
            let environment = Environment(bundle: mockBundle)
            context("when subscription key is available") {
                it("will set the authorization header") {
                    mockBundle.mockSubscriptionKey = "mini-subscription-key"
                    let urlRequest = URLRequest.createURLRequest(url: url, environment: environment)
                    let headerField = urlRequest.value(forHTTPHeaderField: "Authorization")
                    expect(headerField).to(equal("mini-subscription-key"))
                }
            }
            context("when subscription key is not available") {
                it("will not set the authorization header") {
                    mockBundle.mockSubscriptionKey = nil
                    let urlRequest = URLRequest.createURLRequest(url: url, environment: environment)
                    let headerField = urlRequest.value(forHTTPHeaderField: "Authorization")
                    expect(headerField).toEventually(beNil())
                }
            }
        }
    }
}
