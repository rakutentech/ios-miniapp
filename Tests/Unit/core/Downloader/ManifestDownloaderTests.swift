import Quick
import Nimble
@testable import MiniApp

// swiftlint:disable function_body_length
class ManifestDownloaderTests: QuickSpec {

    override func spec() {
        describe("fetch mini apps list") {
            context("when request from server returns valid data") {
                it("will decode the response with ManifestResponse decodable") {
                    let mockAPIClient = MockAPIClient()
                    var decodedResponse: ManifestResponse?
                    let manifestDownloader = ManifestDownloader()
                    let responseString = """
                      {
                        "manifest": [
                            "https://test.com",
                            "\(mockHost)"
                        ]
                      }
                    """
                    mockAPIClient.data = responseString.data(using: .utf8)
                    manifestDownloader.fetchManifest(apiClient: mockAPIClient, appId: "Apple", versionId: "beta", completionHandler: { (result) in
                        switch result {
                        case .success(let responseData):
                            decodedResponse = responseData
                        case .failure:
                            break
                        }
                    })
                    expect(decodedResponse).toEventually(beAnInstanceOf(ManifestResponse.self))
                }
            }
            context("when request from server returns invalid data") {
                it("will decode the response with MiniAppInfo decodable") {
                    let mockAPIClient = MockAPIClient()
                    let manifestDownloader = ManifestDownloader()
                    var testError: MASDKError?
                    let responseString = """
                      {
                        "files": [
                            "https://test.com",
                            "\(mockHost)"
                        ]
                      }
                    """
                    mockAPIClient.data = responseString.data(using: .utf8)
                    manifestDownloader.fetchManifest(apiClient: mockAPIClient, appId: "Apple", versionId: "beta", completionHandler: { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error
                        }
                    })
                    expect(testError?.errorDescription).toEventually(equal(MASDKError.invalidResponseData.errorDescription), timeout: .seconds(30))
                }
            }
            context("when request from server returns error") {
                it("will pass an error with status code and failure completion handler is called") {
                    let mockAPIClient = MockAPIClient()
                    var testError: MASDKError?
                    mockAPIClient.error = MASDKError.unknownError(domain: "Test", code: 123, description: "")
                    let manifestDownloader = ManifestDownloader()
                    manifestDownloader.fetchManifest(apiClient: mockAPIClient, appId: "Apple", versionId: "beta", completionHandler: { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error
                        }
                    })
                    expect(testError?.code).toEventually(equal(123), timeout: .seconds(3))
                }
            }
        }
    }
}
