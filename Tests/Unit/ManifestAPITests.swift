import Quick
import Nimble
@testable import MiniApp

class ManifestAPITests: QuickSpec {

    override func spec() {
        describe("get listing api") {
            let mockBundle = MockBundle()
            mockBundle.mockAppVersion = "1.0"
            let environment = Environment(bundle: mockBundle)
            let manifestAPI = ManifestApi(environment: environment)

            context("when endpoint is properly configured") {
                it("will return valid URL Request") {
                    mockBundle.mockEndpoint = mockHost
                    let urlRequest = manifestAPI.createURLRequest(appId: "1", versionId: "test")
                    expect(urlRequest).to(beAnInstanceOf(URLRequest.self))
                }
            }
            context("when endpoint is not properly configured") {
                it("will return nil") {
                    mockBundle.mockEndpoint = nil
                    let urlRequest = manifestAPI.createURLRequest(appId: "1", versionId: "test")
                    expect(urlRequest).to(beNil())
                }
            }
        }
    }
}
