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
                it("will return valid URL Request for app listing") {
                    mockBundle.mockEndpoint = mockHost
                    expect(listingAPI.createURLRequest()).to(beAnInstanceOf(URLRequest.self))
                }

                it("will return valid URL Request for app info") {
                    mockBundle.mockEndpoint = mockHost
                    expect(listingAPI.createURLRequest(for: "123")).to(beAnInstanceOf(URLRequest.self))
                }
            }
            context("when endpoint is not properly configured") {
                it("will return nil for app listing") {
                    mockBundle.mockEndpoint = nil
                    expect(listingAPI.createURLRequest()).to(beNil())
                }

                it("will return nil for app info") {
                    mockBundle.mockEndpoint = nil
                    expect(listingAPI.createURLRequest(for: "123")).to(beNil())
                }
            }
        }
    }
}
