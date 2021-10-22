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
//        describe("WKUIDelegate") {
//            func createMiniAppView() -> MockRealMiniAppView {
//                return MockRealMiniAppView(
//                    miniAppId: mockMiniAppInfo.id,
//                    versionId: mockMiniAppInfo.version.versionId,
//                    projectId: "project-id",
//                    miniAppTitle: mockMiniAppInfo.displayName!,
//                    hostAppMessageDelegate: MockMessageInterface())
//            }
//            context("when webview is loaded with alert javascript dialog") {
//                it("will show native alert with request message") {
//                    let miniAppView = createMiniAppView()
//                    miniAppView.webView(miniAppView.webView, runJavaScriptAlertPanelWithMessage: "mini-app-alert",
//                                        initiatedByFrame: WKFrameInfo(), completionHandler: {})
//
//                    expect(miniAppView.alertController?.message).to(equal("mini-app-alert"))
//                    expect(miniAppView.alertController?.actions[0].title).to(equal("OK"))
//                }
//                it("will call completion handler when OK is tapped") {
//                    var okTapped = false
//                    let miniAppView = createMiniAppView()
//                    miniAppView.webView(miniAppView.webView, runJavaScriptAlertPanelWithMessage: "mini-app-alert",
//                                        initiatedByFrame: WKFrameInfo(), completionHandler: { okTapped = true })
//
//                    miniAppView.tapButton(.okButton)
//                    expect(okTapped).toEventually(beTrue(), timeout: .seconds(5))
//                }
//            }
//            context("when webview is loaded with confirm javascript dialog") {
//                it("will show native alert with request message, ok and cancel button") {
//                    let miniAppView = createMiniAppView()
//                    miniAppView.webView(miniAppView.webView, runJavaScriptConfirmPanelWithMessage: "mini-app-confirm",
//                                        initiatedByFrame: WKFrameInfo(), completionHandler: {(_) in })
//
//                    expect(miniAppView.alertController?.message).to(equal("mini-app-confirm"))
//                    expect(miniAppView.alertController?.actions[0].title).to(equal("OK"))
//                    expect(miniAppView.alertController?.actions[1].title).to(equal("Cancel"))
//                }
//                it("will return true to completion handler when OK button is tapped") {
//                    var confirm = false
//                    let miniAppView = createMiniAppView()
//                    miniAppView.webView(miniAppView.webView, runJavaScriptConfirmPanelWithMessage: "mini-app-confirm",
//                                        initiatedByFrame: WKFrameInfo(), completionHandler: {(status) in
//                                            confirm = status
//                                        })
//
//                    miniAppView.tapButton(.okButton)
//                    expect(confirm).toEventually(beTrue(), timeout: .seconds(5))
//                }
//                it("will show native alert with request message, ok and cancel button") {
//                    let miniAppView = createMiniAppView()
//                    miniAppView.webView(miniAppView.webView, runJavaScriptConfirmPanelWithMessage: "mini-app-confirm",
//                                        initiatedByFrame: WKFrameInfo(), completionHandler: {(_) in })
//
//                    expect(miniAppView.alertController).toEventuallyNot(beNil(), timeout: .seconds(10))
//                    expect(miniAppView.alertController?.message).to(equal("mini-app-confirm"))
//                    expect(miniAppView.alertController?.actions[0].title).to(equal("OK"))
//                    expect(miniAppView.alertController?.actions[1].title).to(equal("Cancel"))
//                }
//                it("will return false to completion handler when Cancel button is tapped") {
//                    var confirm = true
//                    let miniAppView = createMiniAppView()
//                    miniAppView.webView(miniAppView.webView, runJavaScriptConfirmPanelWithMessage: "mini-app-confirm",
//                                        initiatedByFrame: WKFrameInfo(), completionHandler: {(status) in
//                                            confirm = status
//                                        })
//
//                    miniAppView.tapButton(.cancelButton)
//                    expect(confirm).toEventually(beFalse(), timeout: .seconds(5))
//                }
//            }
//            context("when webview is loaded with prompt javascript dialog") {
//                it("will show native alert with request message and wanted text in textfield") {
//                    let miniAppView = createMiniAppView()
//                    miniAppView.webView(miniAppView.webView, runJavaScriptTextInputPanelWithPrompt: "Please enter your name:",
//                                        defaultText: "Rakuten Mini app", initiatedByFrame: WKFrameInfo(), completionHandler: {(_) in })
//
//                    expect(miniAppView.alertController).toEventuallyNot(beNil(), timeout: .seconds(10))
//                    expect(miniAppView.alertController?.actions[0].title).to(equal("OK"))
//                    expect(miniAppView.alertController?.actions[1].title).to(equal("Cancel"))
//                    expect(miniAppView.alertController?.message).to(equal("Please enter your name:"))
//                    expect(miniAppView.alertController?.textFields?.first?.text).to(equal("Rakuten Mini app"))
//                }
//                it("will return text field value to completion handler when OK button is tapped") {
//                    var userInput: String?
//                    let miniAppView = createMiniAppView()
//                    miniAppView.webView(miniAppView.webView, runJavaScriptTextInputPanelWithPrompt: "Please enter your name:",
//                                        defaultText: "Rakuten Mini app", initiatedByFrame: WKFrameInfo(), completionHandler: {(value) in
//                                            userInput = value
//                                        })
//
//                    miniAppView.tapButton(.okButton)
//                    expect(userInput).toEventually(equal("Rakuten Mini app"), timeout: .seconds(5))
//                }
//                it("will show native alert with request message and wanted no in textfield") {
//                    let miniAppView = createMiniAppView()
//                    miniAppView.webView(miniAppView.webView, runJavaScriptTextInputPanelWithPrompt: "Please enter your name:",
//                                        defaultText: "", initiatedByFrame: WKFrameInfo(), completionHandler: {(_) in })
//
//                    expect(miniAppView.alertController).toEventuallyNot(beNil(), timeout: .seconds(10))
//                    expect(miniAppView.alertController?.actions[0].title).to(equal("OK"))
//                    expect(miniAppView.alertController?.actions[1].title).to(equal("Cancel"))
//                    expect(miniAppView.alertController?.message).to(equal("Please enter your name:"))
//                    expect(miniAppView.alertController?.textFields?.first?.text).to(equal(""))
//                }
//                it("will return nil to completion handler when Cancel button is tapped") {
//                    var userInput: String? = "fake-text"
//                    let miniAppView = createMiniAppView()
//                    miniAppView.webView(miniAppView.webView, runJavaScriptTextInputPanelWithPrompt: "Please enter your name:",
//                                        defaultText: "", initiatedByFrame: WKFrameInfo(), completionHandler: {(value) in
//                                            userInput = value
//                                        })
//
//                    miniAppView.tapButton(.cancelButton)
//                    expect(userInput).toEventually(beNil(), timeout: .seconds(5))
//                }
//            }
//        }
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
