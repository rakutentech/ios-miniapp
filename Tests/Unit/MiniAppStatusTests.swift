import Quick
import Nimble
@testable import MiniApp

class MiniAppStatusTests: QuickSpec {

    override func spec() {
        describe("mini app preferences") {
            context("when setDownloadStatus is called") {
                it("will set status true value for given key") {
                    let miniAppStatus = MiniAppStatus()
                    miniAppStatus.setDownloadStatus(value: true, key: "mini-app/testing")
                    expect(true).toEventually(equal(miniAppStatus.isDownloaded(key: "mini-app/testing")))
                    UserDefaults().removePersistentDomain(forName: "com.rakuten.tech.mobile.miniapp")
                }
                it("will set status false value for given key") {
                    let miniAppStatus = MiniAppStatus()
                    miniAppStatus.setDownloadStatus(value: false, key: "mini-app/testing")
                    expect(false).toEventually(equal(miniAppStatus.isDownloaded(key: "mini-app/testing")))
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
        }
    }
}
