import Quick
import Nimble
@testable import MiniApp

// swiftlint:disable function_body_length
// swiftlint:disable cyclomatic_complexity
class MiniAppDownloaderTests: QuickSpec {
    func manifest(with signatureId: String = "publicKeyId", urls: String...) -> String {
        return  "{\"manifest\": [\"\(urls.joined(separator: "\",\""))\"], \"publicKeyId\": \"\(signatureId)\"}"
    }

    override func spec() {
        let miniAppStatus = MiniAppStatus()
        let appId = "TestMiniApp"
        let versionId = "\(Date().timeIntervalSince1970)"
        let mockAPIClient = MockAPIClient()
        let mockManifestDownloader = MockManifestDownloader()
        let downloader = MiniAppDownloader(apiClient: mockAPIClient, manifestDownloader: mockManifestDownloader, status: miniAppStatus)

        afterEach {
            deleteMockMiniApp(appId: appId, versionId: versionId)
            deleteStatusPreferences()
        }
        describe("mini app folder will be created") {
            context("when manifest returns list of valid URLs") {
                it("will download all files and mini app path is created") {
                    let mockAPIClient = MockAPIClient()
                    let mockManifestDownloader = MockManifestDownloader()
                    let downloader = MiniAppDownloader(apiClient: mockAPIClient, manifestDownloader: mockManifestDownloader, status: miniAppStatus)
                    let responseString = self.manifest(urls: "\(mockHost)/map-published-v2/min-abc/ver-abc/HelloWorld.txt")
                    mockAPIClient.data = responseString.data(using: .utf8)
                    downloader.verifyAndDownload(appId: appId, versionId: versionId) { (result) in
                        switch result {
                        case .success(let url):
                            MiniAppLogger.d(url.absoluteString)
                        case .failure(let error):
                            MiniAppLogger.e("error", error)
                        }
                    }
                    let miniAppDirectory = FileManager.getMiniAppVersionDirectory(with: appId, and: versionId)
                    var isDir: ObjCBool = true
                    expect(FileManager.default.fileExists(atPath: miniAppDirectory.path, isDirectory: &isDir)).toEventually(equal(true), timeout: .seconds(10))
                }
            }
            context("when manifest returns list of valid URLs") {
                it("will download all files and abort if signature is not verified") {
                    let mockAPIClient = MockAPIClient()
                    mockAPIClient.corrupted = true
                    let mockManifestDownloader = MockManifestDownloader()
                    let downloader = MiniAppDownloader(apiClient: mockAPIClient, manifestDownloader: mockManifestDownloader, status: miniAppStatus)
                    let responseString = self.manifest(urls: "\(mockHost)/map-published-v2/min-abc/ver-abc/HelloWorld.txt")
                    mockAPIClient.data = responseString.data(using: .utf8)
                    var downloadFailed = false
                    downloader.verifyAndDownload(appId: appId, versionId: versionId) { (result) in
                        switch result {
                        case .failure:
                            downloadFailed = true
                        default:
                            break

                        }
                    }
                    expect(downloadFailed).toEventually(equal(true), timeout: .seconds(10))
                }
            }
            context("when downloader is failed") {
                it("will return error") {
                    let mockAPIClient = MockAPIClient()
                    let mockManifestDownloader = MockManifestDownloader()
                    let downloader = MiniAppDownloader(apiClient: mockAPIClient, manifestDownloader: mockManifestDownloader, status: miniAppStatus)
                    let responseString = self.manifest(urls: "\(mockHost)/map-published-v2/min-abc/ver-abc/HelloWorld.txt")
                    mockAPIClient.data = responseString.data(using: .utf8)
                    downloader.verifyAndDownload(appId: appId, versionId: versionId) { (_) in }
                    mockManifestDownloader.error = NSError(domain: "URLErrorDomain", code: -1009, userInfo: nil)
                    mockAPIClient.data = nil
                    mockManifestDownloader.data = nil
                    var testError: NSError?
                    downloader.verifyAndDownload(appId: appId, versionId: "\(versionId).1") { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error as NSError
                        }
                    }
                    expect(testError?.code).toEventually(equal(-1009), timeout: .seconds(20))
                }
            }
        }

         describe("old mini app folder will be deleted") {
             context("when manifest returns list of valid URLs") {
                 it("will download all files and remove previous mini app path") {
                     let mockAPIClient = MockAPIClient()
                     let mockManifestDownloader = MockManifestDownloader()
                     let downloader = MiniAppDownloader(apiClient: mockAPIClient, manifestDownloader: mockManifestDownloader, status: miniAppStatus)
                     let responseString = self.manifest(urls: "\(mockHost)/map-published-v2/min-abc/ver-abc/HelloWorld.txt")
                     mockAPIClient.data = responseString.data(using: .utf8)
                     downloader.verifyAndDownload(appId: appId, versionId: "\(versionId).1") { (_) in
                         DispatchQueue.main.asyncAfter(deadline: .now() + 3) { () -> Void in
                             downloader.verifyAndDownload(appId: appId, versionId: "\(versionId).2") { (_) in }
                         }
                     }

                     let miniAppDirectory = FileManager.getMiniAppVersionDirectory(with: appId, and: "\(versionId).2")
                     let oldMiniAppDirectory = FileManager.getMiniAppVersionDirectory(with: appId, and: "\(versionId).1")
                     var isDir: ObjCBool = true

                     expect(FileManager.default.fileExists(atPath: miniAppDirectory.path, isDirectory: &isDir)).toEventually(equal(true), timeout: .seconds(30))
                     expect(FileManager.default.fileExists(atPath: oldMiniAppDirectory.path, isDirectory: &isDir)).toEventually(equal(false), timeout: .seconds(30))
                 }
             }
         }

        describe("old mini app folder will always be deleted in preview mode") {
            context("when manifest returns list of valid URLs") {
                it("will download all files and not keep previous mini app path") {
                    let mockAPIClient = MockAPIClient(previewMode: true)
                    let mockManifestDownloader = MockManifestDownloader()
                    let downloader = MiniAppDownloader(apiClient: mockAPIClient, manifestDownloader: mockManifestDownloader, status: miniAppStatus)
                    let responseString = self.manifest(urls: "\(mockHost)/map-published-v2/min-abc/ver-abc/HelloWorld.txt")
                    var referenceDate: Date? = Date(), dateOld = referenceDate, dateNew = referenceDate
                    let miniAppDirectory = FileManager.getMiniAppVersionDirectory(with: appId, and: versionId)
                    mockAPIClient.data = responseString.data(using: .utf8)
                    downloader.verifyAndDownload(appId: appId, versionId: versionId) { (_) in
                        miniAppStatus.setDownloadStatus(true, for: "\(appId)/\(versionId)")
                        do {
                            try "".write(to: miniAppDirectory.appendingPathComponent("temp.txt"), atomically: true, encoding: .utf8)
                            dateOld = Date()
                        } catch {
                            dateOld = nil
                        }
                        downloader.verifyAndDownload(appId: appId, versionId: versionId) { (_) in
                            dateNew = try? FileManager.default.attributesOfItem(atPath: miniAppDirectory.appendingPathComponent("temp.txt").path)[.creationDate] as? Date
                        }
                    }
                    var isDir: ObjCBool = true

                    expect(FileManager.default.fileExists(atPath: miniAppDirectory.path, isDirectory: &isDir)).toEventually(equal(true), timeout: .seconds(30))
                    expect(dateOld).toEventuallyNot(equal(referenceDate), timeout: .seconds(10))
                    expect(dateOld).toEventuallyNot(beNil(), timeout: .seconds(10))
                    expect(dateNew).toEventually(beNil(), timeout: .seconds(10))
                    deleteStatusPreferences()
                }
            }
        }

        describe("mini app files will be downloaded") {
            context("when valid manifest information is returned") {
                it("will download all files in the manifest") {
                    let mockAPIClient = MockAPIClient()
                    let mockManifestDownloader = MockManifestDownloader()
                    let downloader = MiniAppDownloader(apiClient: mockAPIClient, manifestDownloader: mockManifestDownloader, status: miniAppStatus)
                    let responseString = self.manifest(urls: "\(mockAPIClient.environment.baseUrl?.appendingPathComponent("min-abc/ver-abc/HelloWorld.txt").absoluteString ?? "")",
                                                       "\(mockAPIClient.environment.baseUrl?.appendingPathComponent("min-abc/ver-abc/Testing.txt").absoluteString ?? "")")
                    mockAPIClient.data = responseString.data(using: .utf8)
                    downloader.verifyAndDownload(appId: appId, versionId: versionId) { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure:
                            break
                        }
                    }
                    let miniAppPath = FileManager.getMiniAppVersionDirectory(with: appId, and: versionId)
                    let expectedPath = miniAppPath.appendingPathComponent("HelloWorld.txt")
                    expect(FileManager.default.fileExists(atPath: expectedPath.path)).toEventually(equal(true), timeout: .seconds(30))
                }
            }
        }

        describe("mini app downloader fails") {
            context("when invalid urls is returned") {
                it("will return error") {
                    let mockAPIClient = MockAPIClient()
                    let mockManifestDownloader = MockManifestDownloader()
                    let downloader = MiniAppDownloader(apiClient: mockAPIClient, manifestDownloader: mockManifestDownloader, status: miniAppStatus)
                    let responseString = self.manifest(urls: "test://example.com/map-published-v2/min-abc/ver-abc/Mac/Testing.txt")

                    mockAPIClient.data = responseString.data(using: .utf8)
                    var testError: NSError?
                    downloader.verifyAndDownload(appId: appId, versionId: "\(versionId).fail") { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error as NSError
                        }
                    }
                    expect(testError).toEventuallyNot(beNil())
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
                    downloader.verifyAndDownload(appId: appId, versionId: versionId) { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error as NSError
                        }
                    }
                    expect(testError?.code).toEventually(equal(0), timeout: .seconds(10))
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
                    let responseString = self.manifest(urls: "\(mockHost)/map-published-v2/min-abc/ver-abc/HelloWorld.txt")
                    mockAPIClient.data = responseString.data(using: .utf8)
                    var isDownloaded: Bool = false
                    downloader.verifyAndDownload(appId: appId, versionId: versionId) { (result) in
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
                    expect(version).toEventually(beNil(), timeout: .seconds(10))
                }
            }
            context("when getCachedMiniAppVersion is called with valid mini app id and version id") {
                it("will return version that is already downloaded") {
                    let responseString = self.manifest(urls: "\(mockHost)/map-published-v2/min-abc/ver-abc/HelloWorld.txt")
                    mockAPIClient.data = responseString.data(using: .utf8)
                    var version: String?
                    downloader.verifyAndDownload(appId: appId, versionId: versionId) { (result) in
                        switch result {
                        case .success:
                            miniAppStatus.setDownloadStatus(true, appId: appId, versionId: versionId)
                            miniAppStatus.setCachedVersion(versionId, for: appId)
                            version = downloader.getCachedMiniAppVersion(appId: appId, versionId: versionId)
                        case .failure:
                            break
                        }
                    }
                    expect(version).toEventually(equal(versionId), timeout: .seconds(20))
                }
            }
            context("when getCachedMiniAppVersion is called with valid mini app id and empty version id") {
                it("will return version that is already downloaded") {

                    let responseString = self.manifest(urls: "\(mockHost)/map-published-v2/min-abc/ver-abc/HelloWorld.txt")
                    mockAPIClient.data = responseString.data(using: .utf8)
                    var version: String?
                    downloader.verifyAndDownload(appId: appId, versionId: versionId) { (result) in
                        switch result {
                        case .success:
                            miniAppStatus.setDownloadStatus(true, appId: appId, versionId: versionId)
                            miniAppStatus.setCachedVersion(versionId, for: appId)
                            version = downloader.getCachedMiniAppVersion(appId: appId, versionId: "")
                        case .failure:
                            break
                        }
                    }
                    expect(version).toEventually(equal(versionId), timeout: .seconds(20))
                }
            }
        }
        describe("mini app downloader") {
            context("when receiving a zip file") {
                it("unzips it and delete archive") {
                    let mockAPIClient = MockAPIClient()
                    let mockManifestDownloader = MockManifestDownloader()
                    let downloader = MiniAppDownloader(apiClient: mockAPIClient, manifestDownloader: mockManifestDownloader, status: miniAppStatus)
                    let responseString = self.manifest(urls: "\(mockHost)/map-published-v2/min-abc/ver-abc/SmallMA.zip")
                    mockAPIClient.data = responseString.data(using: .utf8)
                    mockAPIClient.zipFile = Bundle(for: type(of: self)).path(forResource: "SmallMA", ofType: "zip") ?? ""
                    downloader.verifyAndDownload(appId: appId, versionId: versionId) { (_) in }
                    let miniAppDirectory = FileManager.getMiniAppVersionDirectory(with: appId, and: versionId)
                    expect(FileManager.default.fileExists(atPath: "\(miniAppDirectory.path)/index.html")).toEventually(beTrue(), timeout: .seconds(10))
                    expect(FileManager.default.fileExists(atPath: "\(miniAppDirectory.path)/script.js")).toEventually(beTrue(), timeout: .seconds(3))
                    expect(FileManager.default.fileExists(atPath: "\(miniAppDirectory.path)/SmallMA.zip")).toNotEventually(beTrue(), timeout: .seconds(3))
                }
            }
            context("when receiving a corrupted zip file") {
                it("tries to unzips it and delete archive") {
                    let mockAPIClient = MockAPIClient()
                    let mockManifestDownloader = MockManifestDownloader()
                    let downloader = MiniAppDownloader(apiClient: mockAPIClient, manifestDownloader: mockManifestDownloader, status: miniAppStatus)
                    let responseString = self.manifest(urls: "\(mockHost)/map-published-v2/min-abc/ver-abc/SmallMAerror.zip")
                    mockAPIClient.data = responseString.data(using: .utf8)
                    mockAPIClient.zipFile = Bundle(for: type(of: self)).path(forResource: "SmallMAerror", ofType: "zip") ?? ""
                    var error: Error?
                    downloader.verifyAndDownload(appId: appId, versionId: versionId) { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let failed):
                            error = failed
                        }
                    }
                    expect(error).toNotEventually(beNil(), timeout: .seconds(3))
                    let miniAppDirectory = FileManager.getMiniAppVersionDirectory(with: appId, and: versionId)
                    expect(FileManager.default.fileExists(atPath: "\(miniAppDirectory.path)/SmallMAerror.zip")).toNotEventually(beTrue(), timeout: .seconds(3))
                }
            }
        }
    }
}
