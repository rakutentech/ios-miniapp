import Quick
import Nimble
@testable import MiniApp

class URLSchemeHandlerTests: QuickSpec {
    override func spec() {
        describe("URL Scheme Handler") {
            let schemeHandler = URLSchemeHandler(versionId: "version-id")
            var components = URLComponents(string: "mscheme.MINI_APP_ID")
            context("when getAppIdFromScheme is called with scheme") {
                it("will return mini app id") {
                    let appId = schemeHandler.getAppIdFromScheme(scheme: "mscheme.MINI_APP_ID")
                    expect(appId).toEventually(equal("MINI_APP_ID"))
                }
            }
            context("when getFileName is called with url that has valid url path") {
                it("will return realtive file path") {
                    components?.path = "images/home.png"
                    let fileName = schemeHandler.getFileName(url: components?.url)
                    expect(fileName).toEventually(equal(components?.path))
                }
            }
            context("when getFileName is called with url that has invalid url path") {
                it("will return root file path") {
                    components?.path = ""
                    let fileName = schemeHandler.getFileName(url: components?.url)
                    expect(fileName).toEventually(equal(Constants.rootFileName))
                }
            }
            context("when getFilePath is called with valid path") {
                it("will return absolute path of the file") {
                    let miniAppStatus = MiniAppStatus()
                    let mockAPIClient = MockAPIClient()
                    let mockManifestDownloader = MockManifestDownloader()
                    let downloader = MiniAppDownloader(apiClient: mockAPIClient, manifestDownloader: mockManifestDownloader, status: miniAppStatus)
                    let responseString = """
                      {
                        "manifest": ["https://google.com/map-published/min-abc/ver-abc/HelloWorld.txt"]
                      }
                    """
                    mockAPIClient.data = responseString.data(using: .utf8)
                    downloader.download(appId: "Apple", versionId: "Mac") { (_) in }
                    let fileURL = schemeHandler.getFilePath(relativeFilePath: "HelloWorld.txt", appId: "Apple")
                    var expectedFilePath = FileManager.getMiniAppVersionDirectory(with: "Apple", and: "version-id")
                    expectedFilePath.appendPathComponent("HelloWorld.txt")
                    expect(fileURL).toEventually(equal(expectedFilePath))
                }
            }
        }
    }
}
