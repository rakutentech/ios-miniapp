import Quick
import Nimble
import Foundation
@testable import MiniApp

class MiniAppExternalWebViewControllerTests: QuickSpec {

    override func spec() {
        describe("MiniAppExternalWebViewControllerTests") {
            context("when getWebViewConfig method is called") {
                it("will webview config") {
                    let externalController = MiniAppExternalWebViewController()
                    let config = externalController.getWebViewConfig()
                    expect(config.defaultWebpagePreferences.allowsContentJavaScript).to(equal(true))
                    expect(config.allowsInlineMediaPlayback).to(equal(true))
                    expect(config.allowsPictureInPictureMediaPlayback).to(equal(true))
                }
            }
            context("when modally presenting the external web view") {
                it("will present the webview with close navigation controller") {
                    MiniAppExternalWebViewController.presentModally(url: URL(string: "https://www.google.com")!, externalLinkResponseHandler: nil, customMiniAppURL: nil, onCloseHandler: nil)
                    expect(UIApplication.shared.keyWindow()?.topController()!).toEventually(beAnInstanceOf(MiniAppCloseNavigationController.self))
                    UIApplication.shared.keyWindow()?.topController()?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}
