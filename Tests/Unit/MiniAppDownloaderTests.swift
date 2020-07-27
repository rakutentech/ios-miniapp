import Quick
import Nimble
@testable import MiniApp

// swiftlint:disable function_body_length
class MiniAppDownloaderTests: QuickSpec {

    override func spec() {
        let miniAppStatus = MiniAppStatus()
        let appId = "Apple"
        let versionId = "Mac"
        let mockAPIClient = MockAPIClient()
        let mockManifestDownloader = MockManifestDownloader()
        let downloader = MiniAppDownloader(apiClient: mockAPIClient, manifestDownloader: mockManifestDownloader, status: miniAppStatus)
        afterEach {
            deleteMockMiniApp(appId: "Apple", versionId: "Mac")
            deleteStatusPreferences()
        }
        describe("mini app folder will be created") {
            context("when manifest returns list of valid URLs") {
                it("will download all files and mini app path is created") {
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
                    let miniAppDirectory = FileManager.getMiniAppVersionDirectory(with: "Apple", and: "Mac")
                    var isDir: ObjCBool = true
                    expect(FileManager.default.fileExists(atPath: miniAppDirectory.path, isDirectory: &isDir)).toEventually(equal(true), timeout: 10)
                }
            }
            context("when downloader is failed") {
                it("will return error") {
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
                    mockManifestDownloader.error = NSError(domain: "URLErrorDomain", code: -1009, userInfo: nil)
                    mockAPIClient.data = nil
                    mockManifestDownloader.data = nil
                    var testError: NSError?
                    downloader.download(appId: "Apple", versionId: "Mac1") { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error as NSError
                        }
                    }
                    expect(testError?.code).toEventually(equal(-1009), timeout: 20)
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
                        "manifest": ["https://google.com/map-published/min-abc/ver-abc/HelloWorld.txt"]
                      }
                    """
                    mockAPIClient.data = responseString.data(using: .utf8)
                    downloader.download(appId: "testApp", versionId: "1") { (_) in
                        downloader.download(appId: "testApp", versionId: "2") { (_) in }
                    }

                    let miniAppDirectory = FileManager.getMiniAppVersionDirectory(with: "testApp", and: "2")
                    let oldMiniAppDirectory = FileManager.getMiniAppVersionDirectory(with: "testApp", and: "1")
                    var isDir: ObjCBool = true

                    expect(FileManager.default.fileExists(atPath: miniAppDirectory.path, isDirectory: &isDir)).toEventually(equal(true), timeout: 10)
                    expect(FileManager.default.fileExists(atPath: oldMiniAppDirectory.path, isDirectory: &isDir)).toEventually(equal(false), timeout: 10)
                }
            }
        }

        describe("mini app files will be downloaded") {
            context("when valid manifest information is returned") {
                it("will download all files in the manifest") {
                    let mockAPIClient = MockAPIClient()
                    let mockManifestDownloader = MockManifestDownloader()
                    let downloader = MiniAppDownloader(apiClient: mockAPIClient, manifestDownloader: mockManifestDownloader, status: miniAppStatus)
                    let responseString = """
                      {
                        "manifest": ["https://google.com/map-published/min-abc/ver-abc/HelloWorld.txt",
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
                    let expectedPath = miniAppPath.appendingPathComponent("HelloWorld.txt")
                    expect(FileManager.default.fileExists(atPath: expectedPath.path)).toEventually(equal(true), timeout: 10)
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
                        "manifest": ["http://example.com/map-published/min-abc/ver-abc/Mac/Testing.txt"]
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

        describe("mini app downloader") {
            context("when isMiniAppAlreadyDownloaded is called with valid appId and versionId - which is not downloaded") {
              it("will return false") {
                miniAppStatus.setDownloadStatus(true, for: "mini-app/testing")
                let mockAPIClient = MockAPIClient()
                let mockManifestDownloader = MockManifestDownloader()
                let downloader = MiniAppDownloader(apiClient: mockAPIClient, manifestDownloader: mockManifestDownloader, status: miniAppStatus)
                let isDownloaded = downloader.isMiniAppAlreadyDownloaded(appId: "mini-app", versionId: "testing")
                expect(isDownloaded).toEventually(equal(false))
                UserDefaults().removePersistentDomain(forName: "com.rakuten.tech.mobile.miniapp")
              }
            }
            context("when isMiniAppAlreadyDownloaded is called with valid appId and versionId - which is  downloaded") {
              it("will return true") {
                    let responseString = """
                    {
                      "manifest": ["https://google.com/map-published/min-abc/ver-abc/HelloWorld.txt"]
                    }
                    """
                    mockAPIClient.data = responseString.data(using: .utf8)
                    var isDownloaded: Bool = false
                    downloader.download(appId: appId, versionId: versionId) { (result) in
                        switch result {
                        case .success:
                            miniAppStatus.setDownloadStatus(true, appId: appId, versionId: versionId)
                            isDownloaded = downloader.isMiniAppAlreadyDownloaded(appId: appId, versionId: versionId)
                        case .failure:
                            break
                        }
                    }
                    expect(isDownloaded).toEventually(equal(true))
                }
            }
        }
        describe("mini app downloader") {
            context("when getCachedMiniAppVersion is called with invalid data") {
                it("will return nil") {
                    let version = downloader.getCachedMiniAppVersion(appId: "test", versionId: "")
                    expect(version).toEventually(beNil(), timeout: 10)
                }
            }
            context("when getCachedMiniAppVersion is called with valid mini app id and version id") {
                it("will return version that is already downloaded") {
                    let responseString = """
                      {
                        "manifest": ["https://google.com/map-published/min-abc/ver-abc/HelloWorld.txt"]
                      }
                    """
                    mockAPIClient.data = responseString.data(using: .utf8)
                    var version: String?
                    downloader.download(appId: appId, versionId: versionId) { (result) in
                        switch result {
                        case .success:
                            miniAppStatus.setDownloadStatus(true, appId: appId, versionId: versionId)
                            miniAppStatus.setCachedVersion(versionId, for: appId)
                            version = downloader.getCachedMiniAppVersion(appId: appId, versionId: versionId)
                        case .failure:
                            break
                        }
                    }
                    expect(version).toEventually(equal("Mac"), timeout: 20)
                }
            }
            context("when getCachedMiniAppVersion is called with valid mini app id and empty version id") {
                it("will return version that is already downloaded") {

                    let responseString = """
                      {
                        "manifest": ["https://google.com/map-published/min-abc/ver-abc/HelloWorld.txt"]
                      }
                    """
                    mockAPIClient.data = responseString.data(using: .utf8)
                    var version: String?
                    downloader.download(appId: appId, versionId: versionId) { (result) in
                        switch result {
                        case .success:
                            miniAppStatus.setDownloadStatus(true, appId: appId, versionId: versionId)
                            miniAppStatus.setCachedVersion(versionId, for: appId)
                            version = downloader.getCachedMiniAppVersion(appId: appId, versionId: "")
                        case .failure:
                            break
                        }
                    }
                    expect(version).toEventually(equal("Mac"), timeout: 20)
                }
            }
        }
    }
}
