import Quick
import Nimble
@testable import MiniApp

class MiniAppExternalWebViewControllerTests: QuickSpec {

    override func spec() {
        describe("MiniAppExternalWebViewControllerTests") {
            context("when getWebViewConfig method is called") {
                it("will webview config") {
                    let externalController = MiniAppExternalWebViewController()
                    let config = externalController.getWebViewConfig()
                    expect(config.preferences.javaScriptEnabled).to(equal(true))
                    expect(config.allowsInlineMediaPlayback).to(equal(true))
                    expect(config.allowsPictureInPictureMediaPlayback).to(equal(true))
                }
            }
        }
    }
}
