import Quick
import Nimble
@testable import MiniApp

class MiniAppDownloaderTests: QuickSpec {

    override func spec() {
        describe("mini app folder will be created") {
            context("when valid manifest information is returned") {
                it("will be downloaded and path is returned") {
                    let mockAPIClient = MockAPIClient()
                    let downloader = MiniAppDownloader()
                    let responseString = """
                      {
                        "id": "123",
                        "versionTag": "1",
                        "name": "Test",
                        "files": ["https://devstreaming-cdn.apple.com/videos/tutorials/TestFlight_App_Store_Connect_2018/TestFlight_App_Store_Connect_2018_sd.mp4",
                        ]
                      }
                    """
                    mockAPIClient.data = responseString.data(using: .utf8)
                    var miniApp: URL?
                    downloader.download(with: mockAPIClient, appId: "Apple", versionId: "Mac") { (result) in
                        switch result {
                            case .success(let url):
                                miniApp = url
                            case .failure(_):
                                break
                        }
                    }
                    let miniAppPath = FileManager.getMiniAppDirectory(with: "Apple", and: "Mac")
                    expect(miniApp?.path).toEventually(equal(miniAppPath?.path), timeout: 50)
                }
            }
        }
        describe("mini app files will be downloaded") {
            context("when valid manifest information is returned ") {
                it("will be downloaded and path is returned") {
                    let mockAPIClient = MockAPIClient()
                    let downloader = MiniAppDownloader()
                    let responseString = """
                      {
                        "id": "123",
                        "versionTag": "1",
                        "name": "Test",
                        "files": ["https://devstreaming-cdn.apple.com/videos/tutorials/TestFlight_App_Store_Connect_2018/TestFlight_App_Store_Connect_2018_sd.mp4",
                        ]
                      }
                    """
                    mockAPIClient.data = responseString.data(using: .utf8)
                    var miniApp: URL?
                    downloader.download(with: mockAPIClient, appId: "Apple", versionId: "Mac") { (result) in
                        switch result {
                            case .success(let url):
                                miniApp = url
                                miniApp?.appendPathComponent("/devstreaming-cdn.apple.com/videos/tutorials/TestFlight_App_Store_Connect_2018/TestFlight_App_Store_Connect_2018_sd.mp4")
                            case .failure(_):
                                break
                        }
                    }


                    var expectedFilePath = FileManager.getMiniAppDirectory(with: "Apple", and: "Mac")
                expectedFilePath?.appendPathComponent("/devstreaming-cdn.apple.com/videos/tutorials/TestFlight_App_Store_Connect_2018/TestFlight_App_Store_Connect_2018_sd.mp4")

                    expect(miniApp?.path).toEventually(equal(expectedFilePath?.path), timeout: 50)
                }
            }
        }
        describe("mini app download") {
            context("when invalid manifest information is returned") {
                it("will return error") {
                    let mockAPIClient = MockAPIClient()
                    let downloader = MiniAppDownloader()
                    mockAPIClient.data = nil
                    var testError: NSError?
                    downloader.download(with: mockAPIClient, appId: "Apple", versionId: "Mac") { (result) in
                        switch result {
                            case .success(_):
                                break
                            case .failure(let error):
                                testError = error as NSError
                                break
                        }
                    }
                    expect(testError?.code).toEventually(equal(0))
                }
            }
        }
    }
}
