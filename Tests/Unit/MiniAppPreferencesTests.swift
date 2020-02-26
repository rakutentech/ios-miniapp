import Quick
import Nimble
@testable import MiniApp

class MiniAppPreferencesTests: QuickSpec {

    override func spec() {
        describe("mini app preferences") {
            context("when setDownloadStatus is called") {
                it("will set status true value for given key") {
                    let preferences = MiniAppPreferences()
                    preferences.setDownloadStatus(value: true, key: "mini-app/testing")
                    expect(true).toEventually(equal(preferences.isDownloaded(key: "mini-app/testing")))
                    UserDefaults().removePersistentDomain(forName: "com.rakuten.tech.mobile.miniapp")
                }
                it("will set status false value for given key") {
                    let preferences = MiniAppPreferences()
                    preferences.setDownloadStatus(value: false, key: "mini-app/testing")
                    expect(false).toEventually(equal(preferences.isDownloaded(key: "mini-app/testing")))
                    UserDefaults().removePersistentDomain(forName: "com.rakuten.tech.mobile.miniapp")
                }
            }
            context("when unknown key is used") {
                it("will return false") {
                    let preferences = MiniAppPreferences()
                    expect(false).toEventually(equal(preferences.isDownloaded(key: "Test")))
                    UserDefaults().removePersistentDomain(forName: "com.rakuten.tech.mobile.miniapp")
                }
            }
        }
    }
}
