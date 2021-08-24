import Quick
import Nimble
@testable import MiniApp

// swiftlint:disable function_body_length
class MetaDataDownloaderTests: QuickSpec {

    override func spec() {

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
                    metaDataDownloader.getMiniAppMetaInfo(miniAppId: "123", miniAppVersion: "version", apiClient: mockAPIClient, completionHandler: { (result) in
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
        }
    }
}
