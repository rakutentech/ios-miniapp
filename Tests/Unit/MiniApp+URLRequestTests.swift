import Quick
import Nimble
@testable import MiniApp

class MiniAppURLRequestTests: QuickSpec {

    override func spec() {
        describe("create url request") {
            guard let url = URL(string: mockHost) else {
                return
            }
            let mockBundle = MockBundle()
            let environment = Environment(bundle: mockBundle)
            context("when subscription key is available") {
                it("will set the apikey authorization header") {
                    mockBundle.mockSubscriptionKey = "mini-subscription-key"
                    let urlRequest = URLRequest.createURLRequest(url: url, environment: environment)
                    let headerField = urlRequest.value(forHTTPHeaderField: "apiKey")
                    expect(headerField).to(equal("ras-mini-subscription-key"))
                }
            }
            context("when subscription key is not available") {
                it("will not set the apikey authorization header") {
                    mockBundle.mockSubscriptionKey = nil
                    let urlRequest = URLRequest.createURLRequest(url: url, environment: environment)
                    let headerField = urlRequest.value(forHTTPHeaderField: "apiKey")
                    expect(headerField).to(beNil())
                }
            }
        }
    }
}
