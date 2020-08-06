import Quick
import Nimble
@testable import MiniApp

class MiniAppStatusTests: QuickSpec {

    override func spec() {
        describe("mini app preferences") {
            context("when setDownloadStatus is called") {
                it("will set status true value for given key") {
                    let miniAppStatus = MiniAppStatus()
                    miniAppStatus.setDownloadStatus(true, for: "mini-app/testing")
                    expect(true).toEventually(equal(miniAppStatus.isDownloaded(key: "mini-app/testing")))
                    UserDefaults().removePersistentDomain(forName: "com.rakuten.tech.mobile.miniapp")
                }
                it("will set status false value for given key") {
                    let miniAppStatus = MiniAppStatus()
                    miniAppStatus.setDownloadStatus(false, for: "mini-app/testing")
                    expect(false).toEventually(equal(miniAppStatus.isDownloaded(key: "mini-app/testing")))
                    UserDefaults().removePersistentDomain(forName: "com.rakuten.tech.mobile.miniapp")
                }
                it("will set status true for given appId and versionId") {
                    let miniAppStatus = MiniAppStatus()
                    miniAppStatus.setDownloadStatus(true, appId: "mini-app", versionId: "testing")
                    expect(true).toEventually(equal(miniAppStatus.isDownloaded(appId: "mini-app", versionId: "testing")))
                    UserDefaults().removePersistentDomain(forName: "com.rakuten.tech.mobile.miniapp")
                }
                it("will set status false for given appId and versionId") {
                    let miniAppStatus = MiniAppStatus()
                    miniAppStatus.setDownloadStatus(false, appId: "mini-app", versionId: "testing")
                    expect(false).toEventually(equal(miniAppStatus.isDownloaded(appId: "mini-app", versionId: "testing")))
                    UserDefaults().removePersistentDomain(forName: "com.rakuten.tech.mobile.miniapp")
                }
            }
            context("when unknown key is used") {
                it("will return false") {
                    let miniAppStatus = MiniAppStatus()
                    expect(false).toEventually(equal(miniAppStatus.isDownloaded(key: "Test")))
                    UserDefaults().removePersistentDomain(forName: "com.rakuten.tech.mobile.miniapp")
                }
            }
            context("when mini app info is saved") {
                it("will return the miniapp info for a valid mini app id") {
                    let miniAppStatus = MiniAppStatus()
                    miniAppStatus.saveMiniAppInfo(appInfo: mockMiniAppInfo, key: mockMiniAppInfo.id)
                    let retrievedMiniAppInfo = miniAppStatus.getMiniAppInfo(appId: mockMiniAppInfo.id)
                    expect(retrievedMiniAppInfo?.id).toEventually(equal(mockMiniAppInfo.id))
                    expect(retrievedMiniAppInfo?.version.versionId).toEventually(equal(mockMiniAppInfo.version.versionId))
                    UserDefaults().removePersistentDomain(forName: "com.rakuten.tech.mobile.miniapp.MiniAppDemo.MiniAppInfo")
                }
                it("will return nil for a invalid mini app id") {
                    let miniAppStatus = MiniAppStatus()
                    let retrievedMiniAppInfo = miniAppStatus.getMiniAppInfo(appId: "123")
                    expect(retrievedMiniAppInfo).toEventually(beNil())
                    UserDefaults().removePersistentDomain(forName: "com.rakuten.tech.mobile.miniapp.MiniAppDemo.MiniAppInfo")
                }
            }
        }
    }
}
