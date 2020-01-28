import Quick
import Nimble
@testable import MiniApp

class ListingAPITests: QuickSpec {

    override func spec() {
        describe("get listing api") {
            let mockBundle = MockBundle()
            mockBundle.mockAppVersion = "1.0"
            let environment = Environment(bundle: mockBundle)
            let listingAPI = ListingApi(environment: environment)

            context("when endpoint is properly configured") {
                it("will return valid URL Request") {
                    mockBundle.mockEndpoint = "http://example.com"
                    expect(listingAPI.createURLRequest()).toEventually(beAnInstanceOf(URLRequest.self))
                }
            }
            context("when endpoint is not properly configured") {
                it("will return nil") {
                    mockBundle.mockEndpoint = nil
                    expect(listingAPI.createURLRequest()).toEventually(beNil())
                }
            }
        }
    }
}
