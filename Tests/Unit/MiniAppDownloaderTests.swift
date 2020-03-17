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
                        "manifest": ["https://google.com/map-published/Mac/HelloWorld.txt"]
                      }
                    """
                    mockAPIClient.data = responseString.data(using: .utf8)
                    downloader.download(appId: "Apple", versionId: "Mac") { (_) in }
                    let miniAppDirectory = FileManager.getMiniAppVersionDirectory(with: "Apple", and: "Mac")
                    var isDir: ObjCBool = true
                    expect(FileManager.default.fileExists(atPath: miniAppDirectory.path, isDirectory: &isDir)).toEventually(equal(true), timeout: 50)
                }
            }
        }

        describe("old mini app folder will be deleted") {
            context("when manifest returns list of valid URLs") {
                it("will download all files and remove previous mini app path") {
                    let mockAPIClient = MockAPIClient()
                    let mockManifestDownloader = MockManifestDownloader()
                    let downloader = MiniAppDownloader(apiClient: mockAPIClient, manifestDownloader: mockManifestDownloader, status: miniAppStatus)
                    let responseString = """
                      {
                        "manifest": ["https://google.com/map-published/Mac/HelloWorld.txt"]
                      }
                    """
                    mockAPIClient.data = responseString.data(using: .utf8)
                    downloader.download(appId: "testApp", versionId: "1") { (_) in
                        downloader.download(appId: "testApp", versionId: "2") { (_) in }
                    }

                    let miniAppDirectory = FileManager.getMiniAppVersionDirectory(with: "testApp", and: "2")
                    let oldMiniAppDirectory = FileManager.getMiniAppVersionDirectory(with: "testApp", and: "1")
                    var isDir: ObjCBool = true

                    expect(FileManager.default.fileExists(atPath: miniAppDirectory.path, isDirectory: &isDir)).toEventually(equal(true), timeout: 50)
                    expect(FileManager.default.fileExists(atPath: oldMiniAppDirectory.path, isDirectory: &isDir)).toEventually(equal(false), timeout: 50)
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
                        "manifest": ["https://google.com/map-published/Mac/HelloWorld.txt",
                                    "https://google.com/map-published/Mac/Testing.txt"]
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
                    let expectedPath = miniAppPath.appendingPathComponent("HelloWorld.txt")
                    expect(FileManager.default.fileExists(atPath: expectedPath.path)).toEventually(equal(true), timeout: 50)
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
                        "manifest": ["http://example.com/map-published/Mac/Testing.txt"]
                      }
                    """
                    mockAPIClient.data = responseString.data(using: .utf8)
                    var testError: NSError?
                    downloader.download(appId: "Apple", versionId: "MacFails") { (result) in
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
