import Quick
import Nimble
@testable import MiniApp

// swiftlint:disable function_body_length
class RealMiniAppTests: QuickSpec {

    override func spec() {
        let miniAppStatus = MiniAppStatus()
        describe("Real mini app tests") {
            afterEach {
                deleteMockMiniApp(appId: mockMiniAppInfo.id, versionId: mockMiniAppInfo.version.versionId)
                deleteStatusPreferences()
            }
            let realMiniApp = RealMiniApp()
            let mockAPIClient = MockAPIClient()
            realMiniApp.miniAppClient = mockAPIClient
            let mockManifestDownloader = MockManifestDownloader()
            let downloader = MiniAppDownloader(apiClient: mockAPIClient, manifestDownloader: mockManifestDownloader, status: miniAppStatus)
            realMiniApp.manifestDownloader = mockManifestDownloader
            realMiniApp.miniAppDownloader = downloader

            context("when getMiniApp is called with valid app id") {
                it("will return valid MiniAppInfo") {
                    var decodedResponse: MiniAppInfo?
                    let responseString = """
                    [{
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
                    realMiniApp.getMiniApp(miniAppId: "123", completionHandler: { (result) in
                            switch result {
                            case .success(let responseData):
                                decodedResponse = responseData
                            case .failure:
                                break
                        }
                    })
                    expect(decodedResponse).toEventually(beAnInstanceOf(MiniAppInfo.self))
                }
            }
            context("when getMiniApp is called with invalid app id") {
                it("will return valid MiniAppInfo") {
                    var testError: NSError?
                    mockAPIClient.data = nil
                    realMiniApp.getMiniApp(miniAppId: "123", completionHandler: { (result) in
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
            context("when createMiniApp is called valid Mini App info") {
                it("will return valid Mini App View instance") {

                    let responseString = """
                      {
                        "manifest": ["https://example.com/map-published/app-id-test/ver-id-test/HelloWorld.txt"]
                      }
                    """
                    var decodedResponse: MiniAppDisplayProtocol?
                    mockAPIClient.data = responseString.data(using: .utf8)
                    realMiniApp.createMiniApp(appInfo: mockMiniAppInfo, completionHandler: { (result) in
                            switch result {
                            case .success(let responseData):
                                decodedResponse = responseData
                            case .failure:
                                break
                        }
                    })
                    expect(decodedResponse).toEventually(beAnInstanceOf(MiniAppView.self))
                }
            }
            context("when createMiniApp is called with valid Mini App info but failed because of invalid URLs") {
                it("will return error") {
                    let responseString = """
                      {
                        "manifest": ["https://example.com/app-id-test/ver-id-test/HelloWorld.txt"]
                      }
                    """
                    var testError: NSError?
                    mockAPIClient.data = responseString.data(using: .utf8)
                    realMiniApp.createMiniApp(appInfo: mockMiniAppInfo, completionHandler: { (result) in
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
        }
    }
}
