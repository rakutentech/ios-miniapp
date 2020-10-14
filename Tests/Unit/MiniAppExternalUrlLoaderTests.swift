import Quick
import Nimble
import WebKit

@testable import MiniApp

class MiniAppExternalUrlLoaderTests: QuickSpec {

    override func spec() {
        describe("MiniAppExternalUrlLoaderTests") {
            context("when shouldOverrideURLLoading method is called with valid Mini app URL") {
                it("will return WKNavigationActionPolicy as cancel") {
                    let externalURLLoader = MiniAppExternalUrlLoader()
                    let str = URLComponents(string: "mscheme.rakuten://")
                    let navigationPolicy = externalURLLoader.shouldOverrideURLLoading(str?.url)
                    expect(navigationPolicy.rawValue).toEventually(equal(WKNavigationActionPolicy.cancel.rawValue), timeout: .seconds(5))
                }
            }
            context("when shouldOverrideURLLoading method is called with tel URL") {
                it("will return WKNavigationActionPolicy as cancel") {
                    let externalURLLoader = MiniAppExternalUrlLoader()
                    let str = URLComponents(string: "tel://")
                    let navigationPolicy = externalURLLoader.shouldOverrideURLLoading(str?.url)
                    expect(navigationPolicy.rawValue).toEventually(equal(WKNavigationActionPolicy.cancel.rawValue), timeout: .seconds(5))
                }
            }
            context("when shouldOverrideURLLoading method is called with https URL") {
                it("will return WKNavigationActionPolicy as allow") {
                    let externalURLLoader = MiniAppExternalUrlLoader()
                    let str = URLComponents(string: "https://www.google.com")
                    let navigationPolicy = externalURLLoader.shouldOverrideURLLoading(str?.url)
                    expect(navigationPolicy.rawValue).toEventually(equal(WKNavigationActionPolicy.allow.rawValue), timeout: .seconds(5))
                }
            }
        }
    }
}
