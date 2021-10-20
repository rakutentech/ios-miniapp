import Quick
import Nimble
@testable import MiniApp

// swiftlint:disable function_body_length
class PreviewMiniAppFetcherTests: QuickSpec {

    override func spec() {
        describe("fetch mini apps list") {
            context("when request from server returns valid data") {
                it("will decode the response with PreviewMiniAppInfo decodable") {
                    let mockAPIClient = MockAPIClient()
                    var decodedResponse: PreviewMiniAppInfo?
                    let responseString = """
                        {
                           "miniapp":{
                              "id":"123",
                              "displayName":"JS SDK Sample App",
                              "icon":"https://miniappsplatformstg.blob.core.windows.net/map-images/min-23925fa1-260b-43bd-bd7c-4bb256004905/6c4cfa6b-c264-435f-b6a7-73a17fdf120a.png",
                              "version":{
                                 "versionTag":"1.11.2_release",
                                 "versionId":"123"
                              }
                           },
                           "host":null
                        }
                    """
                    mockAPIClient.data = responseString.data(using: .utf8)
                    PreviewMiniAppFetcher().fetchPreviewMiniAppInfo(apiClient: mockAPIClient, using: "TOKEN", completionHandler: { (result) in
                        switch result {
                        case .success(let responseData):
                            decodedResponse = responseData
                        case .failure:
                            break
                        }
                    })
                    expect(decodedResponse).toEventually(beAnInstanceOf(PreviewMiniAppInfo.self))
                }
            }
            context("when request from server returns invalid data") {
                it("will return invalid response data") {
                    let mockAPIClient = MockAPIClient()
                    var sdkError: MASDKError?
                    let responseString = """
                        {
                           "miniapps":{
                              "id":"123",
                              "displayName":"JS SDK Sample App",
                              "icon":"https://miniappsplatformstg.blob.core.windows.net/map-images/min-23925fa1-260b-43bd-bd7c-4bb256004905/6c4cfa6b-c264-435f-b6a7-73a17fdf120a.png",
                              "version":{
                                 "versionTag":"1.11.2_release",
                                 "versionId":"123"
                              }
                           },
                           "hosts":null
                        }
                    """
                    mockAPIClient.data = responseString.data(using: .utf8)
                    PreviewMiniAppFetcher().fetchPreviewMiniAppInfo(apiClient: mockAPIClient, using: "TOKEN", completionHandler: { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            sdkError = error
                        }
                    })
                    expect(sdkError?.errorDescription).toEventually(equal(MASDKError.invalidResponseData.errorDescription))
                }
            }
            context("when invalid token is passed to server") {
                it("will return server error") {
                    var sdkError: MASDKError?
                    PreviewMiniAppFetcher().fetchPreviewMiniAppInfo(apiClient: MiniAppClient(), using: "TOKEN", completionHandler: { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            sdkError = error
                        }
                    })
                    expect(sdkError?.errorDescription).toEventuallyNot(beNil(), timeout: .seconds(5))
                }
            }
        }
    }
}
