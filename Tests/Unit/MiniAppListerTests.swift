import Quick
import Nimble
@testable import MiniApp

class MiniAppListerTests: QuickSpec {

    override func spec() {
        describe("fetch mini apps list") {
            let mockBundle = MockBundle()
            mockBundle.mockEndpoint = "http://www.example.com"

            context("when urlrequest is configured properly") {
                it("will call requestFromServer of mini app client using url request") {
                    let mockAPIClient = MockAPIClient()
                    let miniAppLister = MiniAppLister(environment: Environment())
                    miniAppLister.miniAppClient = mockAPIClient
                    miniAppLister.fetchList(completionHandler: {(_) in })
                    expect(mockAPIClient.request).toEventually(beAnInstanceOf(URLRequest.self))
                }
            }
            context("when listing url is nil") {
                it("will return invalid url error") {
                    let mockAPIClient = MockAPIClient()
                    var testError: NSError?
                    mockBundle.mockEndpoint = ""
                    let miniAppLister = MiniAppLister(environment: Environment(bundle: mockBundle))
                    miniAppLister.miniAppClient = mockAPIClient
                    miniAppLister.fetchList { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error as NSError
                        }
                    }
                    expect(testError?.code).toEventually(equal(0))
                }
            }
            context("when request from server returns valid data") {
                it("will decode the response with MiniAppInfo decodable") {
                    let mockAPIClient = MockAPIClient()
                    var decodedResponse: [MiniAppInfo]?
                    mockBundle.mockEndpoint = "http://www.example.com"
                    let miniAppLister = MiniAppLister(environment: Environment(bundle: mockBundle))
                    miniAppLister.miniAppClient = mockAPIClient
                    let responseString = """
                    [{"id": "123", "name": "Test", "description": "Test", "icon": "https://test.com",
                        "version": { "versionTag": "1.0.0", "versionId": "455"}
                      },{"id": "123", "name": "Test", "description": "Test", "icon": "https://test.com",
                        "version": { "versionTag": "1.0.0", "versionId": "455"}
                      }]
                    """
                    mockAPIClient.data = responseString.data(using: .utf8)
                    miniAppLister.fetchList { (result) in
                        switch result {
                        case .success(let responseData):
                            decodedResponse = responseData
                        case .failure:
                            break
                        }
                    }
                    expect(decodedResponse).toEventually(beAnInstanceOf([MiniAppInfo].self))
                }
            }
            context("when request from server returns invalid data") {
                it("will decode the response with MiniAppInfo decodable") {
                    let mockAPIClient = MockAPIClient()
                    var testError: NSError?
                    mockBundle.mockEndpoint = "http://www.example.com"
                    let miniAppLister = MiniAppLister(environment: Environment(bundle: mockBundle))
                    miniAppLister.miniAppClient = mockAPIClient
                    let responseString = """
                    [{"test": "123", "name": "Test", "description": "Test", "icon": "https://test.com",
                        "version": { "versionTag": "1.0.0", "versionId": "455"}
                      },{"id": "123", "name": "Test", "description": "Test", "icon": "https://test.com",
                        "version": { "versionTag": "1.0.0", "versionId": "455"}
                      }]
                    """
                    mockAPIClient.data = responseString.data(using: .utf8)
                    miniAppLister.fetchList { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error as NSError
                            break
                        }
                    }
                    expect(testError?.code).toEventually(equal(0))
                }
            }
            context("when request from server returns error") {
                it("will pass an error with status code and failure completion handler is called") {
                    let mockAPIClient = MockAPIClient()
                    var testError: NSError?
                    mockBundle.mockEndpoint = "http://www.example.com"
                    mockAPIClient.error = NSError(domain: "Test", code: 123, userInfo: nil)
                    let miniAppLister = MiniAppLister(environment: Environment(bundle: mockBundle))
                    miniAppLister.miniAppClient = mockAPIClient
                    miniAppLister.fetchList { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error as NSError
                            break
                        }
                    }
                    expect(testError?.code).toEventually(equal(123))
                }
            }
        }
    }
}
