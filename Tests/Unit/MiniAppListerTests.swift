import Quick
import Nimble
@testable import MiniApp

// swiftlint:disable function_body_length
class MiniAppListerTests: QuickSpec {

    override func spec() {
        describe("fetch mini apps list") {
            context("when request from server returns valid data") {
                it("will decode the response with MiniAppInfo decodable") {
                    let mockAPIClient = MockAPIClient()
                    var decodedResponse: [MiniAppInfo]?
                    let miniAppLister = MiniAppLister()
                    let responseString = """
                    [
                      {
                        "id": "123",
                        "displayName": "Test",
                        "icon": "https://test.com",
                        "version": {
                            "versionTag": "1.0.0",
                            "versionId": "455"
                        }
                      },{
                        "id": "123",
                        "displayName": "Test",
                        "icon": "https://test.com",
                        "version": {
                            "versionTag": "1.0.0",
                            "versionId": "455"
                        }
                      }]
                    """
                    mockAPIClient.data = responseString.data(using: .utf8)
                    miniAppLister.fetchList(apiClient: mockAPIClient, completionHandler: { (result) in
                        switch result {
                        case .success(let responseData):
                            decodedResponse = responseData
                        case .failure:
                            break
                        }
                    })
                    expect(decodedResponse).toEventually(beAnInstanceOf([MiniAppInfo].self))
                }
            }
            context("when request from server returns invalid data") {
                it("will decode the response with MiniAppInfo decodable") {
                    let mockAPIClient = MockAPIClient()
                    var testError: NSError?
                    let miniAppLister = MiniAppLister()
                    let responseString = """
                    [
                      {
                        "test": "123",
                        "displayName": "Test",
                        "icon": "https://test.com",
                        "version": {
                            "versionTag": "1.0.0",
                            "versionId": "455"
                        }
                      },{
                        "id": "123",
                        "displayName": "Test",
                        "icon": "https://test.com",
                        "version": {
                            "versionTag": "1.0.0",
                            "versionId": "455"
                        }
                      }]
                    """
                    mockAPIClient.data = responseString.data(using: .utf8)
                    miniAppLister.fetchList(apiClient: mockAPIClient, completionHandler: { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error as NSError
                        }
                    })
                    expect(testError?.code).toEventually(equal(0))
                }
            }
            context("when request from server returns error") {
                it("will pass an error with status code and failure completion handler is called") {
                    let mockAPIClient = MockAPIClient()
                    var testError: NSError?
                    mockAPIClient.error = NSError(
                        domain: "Test",
                        code: 123,
                        userInfo: nil
                    )
                    let miniAppLister = MiniAppLister()
                    miniAppLister.fetchList(apiClient: mockAPIClient, completionHandler: { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error as NSError
                        }
                    })
                    expect(testError?.code).toEventually(equal(123))
                }
            }
        }
    }
}
