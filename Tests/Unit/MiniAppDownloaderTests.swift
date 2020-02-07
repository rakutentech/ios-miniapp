import Quick
import Nimble
@testable import MiniApp

// swiftlint:disable function_body_length
class MiniAppDownloaderTests: QuickSpec {

    override func spec() {
        describe("mini app folder will be created") {
            context("when valid manifest information is returned") {
                it("will be downloaded and path is returned") {
                    let mockAPIClient = MockAPIClient()
                    let mockManifestDownloader = MockManifestDownloader()
                    let downloader = MiniAppDownloader(apiClient: mockAPIClient, manifestDownloader: mockManifestDownloader)
                    let responseString = """
                      {
                        "id": "123",
                        "versionTag": "1",
                        "name": "Test",
                        "files": ["https://google.com/version/Mac/HelloWorld.txt"]
                      }
                    """
                    mockAPIClient.data = responseString.data(using: .utf8)
                    var isDownloaded: Bool?
                    downloader.download(appId: "Apple", versionId: "Mac") { (result) in
                        switch result {
                        case .success(let status):
                            isDownloaded = status
                            break
                        case .failure:
                            break
                        }
                    }
                    expect(isDownloaded).toEventually(equal(true), timeout: 50)
                }
            }
        }
        describe("mini app files will be downloaded") {
            context("when valid manifest information is returned ") {
                it("will return downloading failed error") {
                    let mockAPIClient = MockAPIClient()
                    let mockManifestDownloader = MockManifestDownloader()
                    let downloader = MiniAppDownloader(apiClient: mockAPIClient, manifestDownloader: mockManifestDownloader)
                    let responseString = """
                      {
                        "id": "123",
                        "versionTag": "1",
                        "name": "Test",
                        "files": ["https://google.com/version/Mac/HelloWorld.txt"]
                      }
                    """
                    mockAPIClient.data = responseString.data(using: .utf8)
                    downloader.download(appId: "Apple", versionId: "Mac") { (result) in
                        switch result {
                        case .success(_):
                            break
                        case .failure:
                            break
                        }
                    }
                    let miniAppPath = FileManager.getMiniAppDirectory(with: "Apple", and: "Mac")
                    guard let expectedPath = miniAppPath?.appendingPathComponent("HelloWorld.txt") else {
                        return
                    }
                    let isFileExists = FileManager.default.fileExists(atPath: expectedPath.path)
                    expect(isFileExists).toEventually(equal(true), timeout: 50)
                }
            }
        }
        describe("mini app files will be downloaded") {
            context("when invalid urls is returned") {
                it("will be downloaded and path is returned") {
                    let mockAPIClient = MockAPIClient()
                    let mockManifestDownloader = MockManifestDownloader()
                    let downloader = MiniAppDownloader(apiClient: mockAPIClient, manifestDownloader: mockManifestDownloader)
                    let responseString = """
                      {
                        "id": "123",
                        "versionTag": "1",
                        "name": "Test",
                        "files": ["http://example.com/version/Mac/Testing.txt"]
                      }
                    """
                    mockAPIClient.data = responseString.data(using: .utf8)
                    var testError: NSError?
                    downloader.download(appId: "Apple", versionId: "Mac") { (result) in
                        switch result {
                        case .success(_):
                            break
                        case .failure(let error):
                            testError = error as NSError
                        }
                    }
                    expect(testError?.code).toEventually(equal(-1022),timeout: 20)
                }
            }
        }
        describe("mini app download") {
            context("when invalid manifest information is returned") {
                it("will return error") {
                    let mockAPIClient = MockAPIClient()
                    let mockManifestDownloader = MockManifestDownloader()
                    let downloader = MiniAppDownloader(apiClient: mockAPIClient, manifestDownloader: mockManifestDownloader)
                    mockAPIClient.data = nil
                    var testError: NSError?
                    downloader.download(appId: "Apple", versionId: "Mac") { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error as NSError
                        }
                    }
                    expect(testError?.code).toEventually(equal(0),timeout: 10)
                }
            }
        }
    }
}
