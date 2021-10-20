import Quick
import Nimble
@testable import MiniApp
import WebKit

// swiftlint:disable function_body_length
class RealMiniAppViewTests: QuickSpec {
    override func spec() {

        describe("Mini App view") {
            let mockMessageInterface = MockMessageInterface()
            let miniAppView = RealMiniAppView(miniAppId: "miniappid-testing",
                                              versionId: "version-id",
                                              projectId: "project-id",
                                              miniAppTitle: "Mini app title",
                                              hostAppMessageDelegate: mockMessageInterface)
            context("when initialized with valid parameters") {
                it("will return MiniAppView object for given app id") {
                    let miniAppView = RealMiniAppView(miniAppId: "miniappid-testing",
                                                      versionId: "version-id",
                                                      projectId: "project-id",
                                                      miniAppTitle: "",
                                                      hostAppMessageDelegate: mockMessageInterface)
                    expect(miniAppView).to(beAnInstanceOf(RealMiniAppView.self))
                }
                it("will return MiniAppView object for given app url") {
                    let miniAppView = RealMiniAppView(miniAppURL: URL(string: "http://miniapp")!,
                                                      miniAppTitle: "",
                                                      hostAppMessageDelegate: mockMessageInterface)
                    expect(miniAppView).to(beAnInstanceOf(RealMiniAppView.self))
                }
            }
            context("when getMiniAppView is called") {
                it("will return object of UIView type") {
                    expect(miniAppView.getMiniAppView()).to(beAKindOf(UIView.self))
                }
            }
            context("when host app info is specified in plist") {
                it("will add custom string in User agent") {
                    let miniAppView = RealMiniAppView(
                        miniAppId: "miniappid-testing",
                        versionId: "version-id",
                        projectId: "project-id",
                        miniAppTitle: "",
                        hostAppMessageDelegate: mockMessageInterface)
                    expect(miniAppView.webView.customUserAgent).toEventually(contain("MiniApp Demo App"), timeout: .seconds(30))
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
                    let miniAppView = RealMiniAppView(
                        miniAppId: "miniappid-testing",
                        versionId: "version-id",
                        projectId: "project-id",
                        miniAppTitle: "",
                        hostAppMessageDelegate: mockMessageInterface,
                        displayNavBar: .never
                    )
                    miniAppView.refreshNavBar()
                    expect(miniAppView.navBar).to(beNil())
                }
            }
            context("when initialized with navigation parameter set to always") {
                it("will return MiniAppView with navigation visible") {
                    let miniAppView = RealMiniAppView(
                        miniAppId: "miniappid-testing",
                        versionId: "version-id",
                        projectId: "project-id",
                        miniAppTitle: "",
                        hostAppMessageDelegate: mockMessageInterface,
                        displayNavBar: .always
                    )
                    miniAppView.refreshNavBar()
                    expect(miniAppView.navBar).to(beAKindOf(MiniAppNavigationBar.self))
                    let bar = (miniAppView.navBar as? MiniAppNavigationBar)
                    bar?.buttonTaped(bar!.backButton)
                    bar?.buttonTaped(bar!.forwardButton)
                    bar?.buttonTaped(UIBarButtonItem())
                    expect(miniAppView.webViewBottomConstraintWithNavBar?.isActive).to(beTrue())
                }
            }
            context("when initialized with navigation parameter set to auto") {
                it("will return MiniAppView with navigation hidden") {
                    let miniAppView = RealMiniAppView(
                        miniAppId: "miniappid-testing",
                        versionId: "version-id", projectId: "project-id", miniAppTitle: "",
                        hostAppMessageDelegate: mockMessageInterface,
                        displayNavBar: .auto
                    )
                    miniAppView.refreshNavBar()
                    expect(miniAppView.navBar).toNot(beNil())
                    expect(miniAppView.webViewBottomConstraintWithNavBar?.isActive).toNot(beTrue())
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
                        miniAppId: "miniappid-testing", versionId: "version-id", projectId: "project-id", miniAppTitle: "",
                        hostAppMessageDelegate: mockMessageInterface,
                        displayNavBar: .never,
                        navigationDelegate: customNav,
                        navigationView: customNav
                    )
                    miniAppView.refreshNavBar()
                    expect(miniAppView.navBar).to(beNil())
                }
            }
            context("when initialized with navigation parameter set to always") {
                it("will return MiniAppView with navigation visible") {
                    let miniAppView = RealMiniAppView(
                        miniAppId: "miniappid-testing", versionId: "version-id", projectId: "project-id", miniAppTitle: "",
                        hostAppMessageDelegate: mockMessageInterface,
                        displayNavBar: .always,
                        navigationDelegate: customNav, navigationView: customNav
                    )
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
                        miniAppId: "miniappid-testing", versionId: "version-id", projectId: "project-id", miniAppTitle: "",
                        hostAppMessageDelegate: mockMessageInterface,
                        displayNavBar: .auto,
                        navigationDelegate: customNav,
                        navigationView: customNav
                    )
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
