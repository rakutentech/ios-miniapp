import Quick
import Nimble
@testable import MiniApp

// swiftlint:disable function_body_length
class LocalServerTests: QuickSpec {

    override func spec() {
        describe("Local Server") {
            context("when appId and versionId is passed and isSecure is false") {
                it("will start local server with http host") {
                    let server = LocalServer()
                    server.startServer(appId: "apple", versionId: "ios", isSecure: false)
                    print(server.serverURL())
                    expect(server.serverURL().absoluteString).toEventually(contain("http://localhost"), timeout: 10)
                    server.stopServer()
                }
            }
            context("when appId and versionId is passed and isSecure is true") {
                it("will start local server with https host") {
                    let server = LocalServer()
                    server.startServer(appId: "apple", versionId: "ios", isSecure: true)
                    print(server.serverURL())
                    expect(server.serverURL().absoluteString).toEventually(contain("https://localhost"), timeout: 10)
                    server.stopServer()
                }
            }
            context("when valid appId and versionId is passed and isSecure is true") {
                it("will download all files in the manifest") {
                    let localServer = LocalServer()
                    let miniAppStatus = MiniAppStatus()
                    let mockAPIClient = MockAPIClient()
                    let mockManifestDownloader = MockManifestDownloader()
                    let downloader = MiniAppDownloader(apiClient: mockAPIClient, manifestDownloader: mockManifestDownloader, status: miniAppStatus)
                    let responseString = """
                      {
                        "manifest": ["https://google.com/map-published/min-abc/ver-abc/index.html",
                                    "https://google.com/map-published/min-abc/ver-abc/Testing.txt"]
                      }
                    """
                    mockAPIClient.data = responseString.data(using: .utf8)
                    downloader.download(appId: "Apple", versionId: "Mac") { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure:
                            break
                        }
                    }
                    let miniAppPath = FileManager.getMiniAppVersionDirectory(with: "Apple", and: "Mac")
                    let expectedPath = miniAppPath.appendingPathComponent("index.html")
                    expect(FileManager.default.fileExists(atPath: expectedPath.path)).toEventually(equal(true), timeout: 10)
                    localServer.startServer(appId: "Apple", versionId: "Mac", isSecure: true)
                    expect(localServer.server?.isRunning).toEventually(equal(true), timeout: 10)
                    localServer.stopServer()
                }
            }
        }
    }
}
