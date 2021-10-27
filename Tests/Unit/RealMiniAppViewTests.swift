import Quick
import Nimble
@testable import MiniApp
import WebKit

// swiftlint:disable function_body_length
class RealMiniAppViewTests: QuickSpec {
    override func spec() {

        describe("Mini App view") {
            let mockMessageInterface = MockMessageInterface()
            let miniAppView = RealMiniAppView(miniAppId: mockMiniAppInfo.id,
                                              versionId: mockMiniAppInfo.version.versionId,
                                              projectId: "project-id",
                                              miniAppTitle: mockMiniAppInfo.displayName!,
                                              hostAppMessageDelegate: mockMessageInterface)

            context("when SDK should send event") {
                beforeEach {
                    miniAppView.messageBodies = []
                }
                it("will send pause to MiniApp when host app enters background") {
                    NotificationCenter.default.post(name: UIApplication.willResignActiveNotification, object: nil)
                    expect(miniAppView.messageBodies.count).toEventually(be(1))
                    expect(miniAppView.messageBodies[0]).toEventually(contain(MiniAppEvent.pause.rawValue))
                }
                it("will send resume to MiniApp when host app enters foreground") {
                    NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)
                    expect(miniAppView.messageBodies.count).toEventually(be(1))
                    expect(miniAppView.messageBodies[0]).toEventually(contain(MiniAppEvent.resume.rawValue))
                }
                it("will send pause to MiniApp when it opens an external webview") {
                    miniAppView.validateScheme(requestURL: URL(string: "https://test.com")!, navigationAction: WKNavigationAction()) { _ in }
                    expect(miniAppView.messageBodies.count).toEventually(be(1))
                    expect(miniAppView.messageBodies[0]).toEventually(contain(MiniAppEvent.pause.rawValue))
                }
                it("will send resume to MiniApp when it closes an external webview") {
                    miniAppView.onExternalWebviewClose?(URL(string: "https://test.com")!)
                    expect(miniAppView.messageBodies.count).toEventually(be(2))
                    expect(miniAppView.messageBodies[1]).toEventually(contain(MiniAppEvent.resume.rawValue))
                    expect(miniAppView.messageBodies[0]).toEventually(contain(MiniAppEvent.externalWebViewClosed.rawValue))
                }
            }

            context("when initialized with valid parameters") {
                it("will return MiniAppView object for given app id") {
                    let miniAppView = RealMiniAppView(miniAppId: mockMiniAppInfo.id,
                                                      versionId: mockMiniAppInfo.version.versionId,
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
                        miniAppId: mockMiniAppInfo.id,
                        versionId: mockMiniAppInfo.version.versionId,
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
                        miniAppId: mockMiniAppInfo.id,
                        versionId: mockMiniAppInfo.version.versionId,
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
                        miniAppId: mockMiniAppInfo.id,
                        versionId: mockMiniAppInfo.version.versionId,
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
                        miniAppId: mockMiniAppInfo.id,
                        versionId: mockMiniAppInfo.version.versionId, projectId: "project-id", miniAppTitle: "",
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
                        miniAppId: mockMiniAppInfo.id, versionId: mockMiniAppInfo.version.versionId, projectId: "project-id", miniAppTitle: "",
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
                        miniAppId: mockMiniAppInfo.id, versionId: mockMiniAppInfo.version.versionId, projectId: "project-id", miniAppTitle: "",
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
                        miniAppId: mockMiniAppInfo.id, versionId: mockMiniAppInfo.version.versionId, projectId: "project-id", miniAppTitle: "",
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
            context("when trying to request a base64 url") {
                let miniAppView = RealMiniAppView(
                    miniAppId: mockMiniAppInfo.id,
                    versionId: mockMiniAppInfo.version.versionId,
                    projectId: "project-id",
                    miniAppTitle: "",
                    hostAppMessageDelegate: mockMessageInterface,
                    displayNavBar: .always,
                    navigationDelegate: customNav,
                    navigationView: customNav
                )

                let base64Url = URL(string: getExampleBase64String())!

                it("should return base64 url when permission is allowed") {
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .fileDownload, status: .allowed)

                    var resultUrl: URL?
                    customNav.onNavigateToUrl = { resultUrl = $0 }

                    miniAppView.webView.load(URLRequest(url: base64Url))
                    expect(resultUrl).toEventuallyNot(beNil(), timeout: .seconds(3))
                }

                it("should not return base64 url when permission is denied") {
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .fileDownload, status: .denied)

                    waitUntil(timeout: .seconds(3), action: { done in
                        customNav.onNavigateToUrl = { _ in
                            fail("should not navigate")
                        }
                        miniAppView.webView.load(URLRequest(url: base64Url))
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                            done()
                        }
                    })
                }
            }
        }
    }
}
