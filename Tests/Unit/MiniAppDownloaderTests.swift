import Quick
import Nimble
@testable import MiniApp

// swiftlint:disable function_body_length
class MiniAppDownloaderTests: QuickSpec {

    override func spec() {
        let miniAppStatus = MiniAppStatus()
        describe("mini app folder will be created") {
            context("when manifest returns list of valid URLs") {
                it("will download all files and mini app path is created") {
                    let mockAPIClient = MockAPIClient()
                    let mockManifestDownloader = MockManifestDownloader()
                    let downloader = MiniAppDownloader(apiClient: mockAPIClient, manifestDownloader: mockManifestDownloader, status: miniAppStatus)
                    let responseString = """
                      {
                        "manifest": ["https://google.com/version/Mac/HelloWorld.txt"]
                      }
                    """
                    mockAPIClient.data = responseString.data(using: .utf8)
                    var isFolderExists: Bool?
                    downloader.download(appId: "Apple", versionId: "Mac") { (result) in
                        switch result {
                        case .success:
                            let miniAppDirectory = FileManager.getMiniAppDirectory(with: "Apple", and: "Mac")
                            var isDir: ObjCBool = true
                            isFolderExists = FileManager.default.fileExists(atPath: miniAppDirectory.path, isDirectory: &isDir)
                        case .failure:
                            break
                        }
                    }
                    expect(isFolderExists).toEventually(equal(true), timeout: 50)
                }
            }
        }

        describe("mini app files will be downloaded") {
            context("when valid manifest information is returned ") {
                it("will return downloading failed error") {
                    let mockAPIClient = MockAPIClient()
                    let mockManifestDownloader = MockManifestDownloader()
                    let downloader = MiniAppDownloader(apiClient: mockAPIClient, manifestDownloader: mockManifestDownloader, status: miniAppStatus)
                    let responseString = """
                      {
                        "manifest": ["https://google.com/version/Mac/HelloWorld.txt",
                                    "https://google.com/version/Mac/Testing.txt"]
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
                    let miniAppPath = FileManager.getMiniAppDirectory(with: "Apple", and: "Mac")
                    let expectedPath = miniAppPath.appendingPathComponent("HelloWorld.txt")
                    let isFileExists = FileManager.default.fileExists(atPath: expectedPath.path)
                    expect(isFileExists).toEventually(equal(true), timeout: 50)
                }
            }
        }
        describe("mini app downloader fails") {
            context("when invalid urls is returned") {
                it("will return error") {
                    let mockAPIClient = MockAPIClient()
                    let mockManifestDownloader = MockManifestDownloader()
                    let downloader = MiniAppDownloader(apiClient: mockAPIClient, manifestDownloader: mockManifestDownloader, status: miniAppStatus)
                    let responseString = """
                      {
                        "manifest": ["http://example.com/version/Mac/Testing.txt"]
                      }
                    """
                    mockAPIClient.data = responseString.data(using: .utf8)
                    var testError: NSError?
                    downloader.download(appId: "Apple", versionId: "Mac") { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error as NSError
                        }
                    }
                    expect(testError?.code).toEventually(equal(-1022), timeout: 20)
                }
            }
        }
        describe("mini app download") {
            context("when invalid manifest information is returned") {
                it("will return error") {
                    let mockAPIClient = MockAPIClient()
                    let mockManifestDownloader = MockManifestDownloader()
                    let downloader = MiniAppDownloader(apiClient: mockAPIClient, manifestDownloader: mockManifestDownloader, status: miniAppStatus)
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
                    expect(testError?.code).toEventually(equal(0), timeout: 10)
                }
            }
        }
    }
}
