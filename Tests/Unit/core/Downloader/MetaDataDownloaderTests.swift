import Quick
import Nimble
@testable import MiniApp

// swiftlint:disable function_body_length
class MetaDataDownloaderTests: QuickSpec {

    override func spec() {

        beforeEach {
            let manifestStorage = MAManifestStorage()
            manifestStorage.removeKey(forMiniApp: mockMiniAppInfo.id)
        }
        describe("fetch mini app meta data") {
            context("when request from server returns valid data") {
                it("will decode the response with MiniAppManifest decodable") {
                    let mockAPIClient = MockAPIClient()
                    var decodedResponse: MiniAppManifest?
                    let metaDataDownloader = MetaDataDownloader()
                    let responseString = """
                        {
                            "bundleManifest": {
                                  "reqPermissions": [
                                    {
                                      "name": "rakuten.miniapp.user.USER_NAME",
                                      "reason": "Describe your reason here (optional)."
                                    },
                                    {
                                      "name": "rakuten.miniapp.user.PROFILE_PHOTO",
                                      "reason": "Describe your reason here (optional)."
                                    }
                                  ],
                                  "optPermissions": [
                                    {
                                      "name": "rakuten.miniapp.user.CONTACT_LIST",
                                      "reason": "Describe your reason here (optional)."
                                    },
                                    {
                                      "name": "rakuten.miniapp.device.LOCATION",
                                      "reason": "Describe your reason here (optional)."
                                    }
                                  ],
                                  "customMetaData": {
                                    "exampleKey": "test"
                                  }
                            }
                        }
                    """
                    mockAPIClient.data = responseString.data(using: .utf8)
                    metaDataDownloader.getMiniAppMetaInfo(miniAppId: mockMiniAppInfo.id,
                                                          miniAppVersion: mockMiniAppInfo.version.versionId,
                                                          apiClient: mockAPIClient, completionHandler: { (result) in
                        switch result {
                        case .success(let responseData):
                            decodedResponse = responseData
                        case .failure:
                            break
                        }
                    })
                    expect(decodedResponse).toEventually(beAnInstanceOf(MiniAppManifest.self))
                }
            }
            context("when request from server returns no data") {
                it("will return error") {
                    let mockAPIClient = MockAPIClient()
                    let metaDataDownloader = MetaDataDownloader()
                    var testError: NSError?
                    metaDataDownloader.getMiniAppMetaInfo(miniAppId: mockMiniAppInfo.id,
                                                          miniAppVersion: mockMiniAppInfo.version.versionId,
                                                          apiClient: mockAPIClient, completionHandler: { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error as NSError
                        }
                    })
                    expect(testError).notTo(beNil())
                }
            }
            context("when request from server returns invalid data") {
                it("will decode the response with MiniAppManifest decodable") {
                    let mockAPIClient = MockAPIClient()
                    let metaDataDownloader = MetaDataDownloader()
                    var testError: MASDKError?
                    let responseString = """
                        {
                            "manifest": {
                                  "requiredPermissions": [
                                    {
                                      "name": "rakuten.miniapp.user.USER_NAME",
                                      "reason": "Describe your reason here (optional)."
                                    }
                                  ]
                            }
                        }
                    """
                    mockAPIClient.data = responseString.data(using: .utf8)
                    metaDataDownloader.getMiniAppMetaInfo(miniAppId: mockMiniAppInfo.id,
                                                          miniAppVersion: mockMiniAppInfo.version.versionId,
                                                          apiClient: mockAPIClient, completionHandler: { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error as MASDKError
                        }
                    })
                    expect(testError?.errorDescription).toEventually(equal(MASDKError.invalidResponseData.errorDescription))
                }
            }
        }
    }
}
