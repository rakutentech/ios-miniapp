import Quick
import Nimble
@testable import MiniApp
@testable import WebKit

class RealMiniAppViewTests: QuickSpec {
    override func spec() {
        describe("Mini App view") {
            let mockMessageInterface = MockMessageInterface()
            context("when initialized with valid parameters") {
                it("will return MiniAppView object") {
                    let miniAppView = RealMiniAppView(miniAppId: "miniappid-testing", versionId: "version-id", hostAppMessageDelegate: mockMessageInterface)
                    expect(miniAppView).toEventually(beAnInstanceOf(RealMiniAppView.self))
                }
            }
            context("when getMiniAppView is called") {
                it("will return object of UIView type") {
                    let miniAppView = RealMiniAppView(miniAppId: "miniappid-testing", versionId: "version-id", hostAppMessageDelegate: mockMessageInterface)
                    expect(miniAppView.getMiniAppView()).toEventually(beAKindOf(UIView.self))
                }
            }
        }
    }
}

class RealMiniAppViewNavigationTests: QuickSpec {
    override func spec() {
        describe("Mini App view navigation") {
            let mockMessageInterface = MockMessageInterface()
            context("when initialized with navigation parameter set to never") {
                it("will return MiniAppView without navigation") {
                    let miniAppView = RealMiniAppView(miniAppId: "miniappid-testing", versionId: "version-id", hostAppMessageDelegate: mockMessageInterface, displayNavBar: .never)
                    miniAppView.refreshNavBar()
                    expect(miniAppView.navBar).to(beNil())
                }
            }
            context("when initialized with navigation parameter set to always") {
                it("will return MiniAppView with navigation visible") {
                    let miniAppView = RealMiniAppView(miniAppId: "miniappid-testing", versionId: "version-id", hostAppMessageDelegate: mockMessageInterface, displayNavBar: .always)
                    miniAppView.refreshNavBar()
                    expect(miniAppView.navBar).to(beAKindOf(MiniAppNavigationBar.self))
                    let bar = (miniAppView.navBar as? MiniAppNavigationBar)
                    bar?.buttonTaped(bar!.backButton)
                    bar?.buttonTaped(bar!.forwardButton)
                    bar?.buttonTaped(UIBarButtonItem())
                    expect(miniAppView.wevViewBottonConstraintWithNavBar?.isActive).to(beTrue())
                }
            }
            context("when initialized with navigation parameter set to auto") {
                it("will return MiniAppView with navigation hidden") {
                    let miniAppView = RealMiniAppView(miniAppId: "miniappid-testing", versionId: "version-id", hostAppMessageDelegate: mockMessageInterface, displayNavBar: .auto)
                    miniAppView.refreshNavBar()
                    expect(miniAppView.navBar).toNot(beNil())
                    expect(miniAppView.wevViewBottonConstraintWithNavBar?.isActive).toNot(beTrue())
                }
            }
        }
    }
}

class RealMiniAppViewCustomNavigationTests: QuickSpec {
    override func spec() {
        describe("Mini App view custom navigation") {
            let customNav = MockNavigationView(frame: .zero)
            let nav = WKNavigation()
            let mockMessageInterface = MockMessageInterface()
            context("when initialized with navigation parameter set to never") {
                it("will return MiniAppView without navigation") {
                    let miniAppView = RealMiniAppView(
                        miniAppId: "miniappid-testing", versionId: "version-id",
                        hostAppMessageDelegate: mockMessageInterface,
                        displayNavBar: .never, navigationDelegate: customNav, navigationView: customNav)
                    miniAppView.refreshNavBar()
                    expect(miniAppView.navBar).to(beNil())
                }
            }
            context("when initialized with navigation parameter set to always") {
                it("will return MiniAppView with navigation visible") {
                    let miniAppView = RealMiniAppView(
                        miniAppId: "miniappid-testing", versionId: "version-id", hostAppMessageDelegate: mockMessageInterface,
                        displayNavBar: .always, navigationDelegate: customNav, navigationView: customNav)
                    miniAppView.refreshNavBar()
                    customNav.actionGoBack()
                    customNav.actionGoForward()
                    expect(miniAppView.navBar).to(be(customNav))
                    expect(miniAppView.navBar?.superview).toNot(beNil())
                }
            }
            context("when initialized with navigation parameter set to auto") {
                it("will return MiniAppView with navigation hidden") {
                    let miniAppView = RealMiniAppView(
                        miniAppId: "miniappid-testing", versionId: "version-id", hostAppMessageDelegate: mockMessageInterface,
                        displayNavBar: .auto, navigationDelegate: customNav, navigationView: customNav)
                    miniAppView.refreshNavBar()
                    let webvtest = MockNavigationWebView(miniAppId: "test", versionId: "test")
                    miniAppView.webView = webvtest
                    webvtest.navigationDelegate = miniAppView
                    expect(miniAppView.navBar).to(be(customNav))
                    expect(miniAppView.navBar?.superview).to(beNil())
                    miniAppView.webView(miniAppView.webView, didFinish: nav)
                    customNav.actionGoBack()
                    customNav.actionGoForward()
                    expect(miniAppView.navBar?.superview).toNot(beNil())
                }
            }
        }
    }
}
