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
                    expect(miniAppView).toEventually(beAnInstanceOf(RealMiniAppView.self))
                }
                it("will return MiniAppView object for given app url") {
                    let miniAppView = RealMiniAppView(miniAppURL: URL(string: "http://miniapp")!,
                                                      miniAppTitle: "",
                                                      hostAppMessageDelegate: mockMessageInterface)
                    expect(miniAppView).toEventually(beAnInstanceOf(RealMiniAppView.self))
                }
            }
            context("when getMiniAppView is called") {
                it("will return object of UIView type") {
                    expect(miniAppView.getMiniAppView()).toEventually(beAKindOf(UIView.self))
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
                    expect(miniAppView.webView.customUserAgent).toEventually(contain("MiniApp Demo App"), timeout: .seconds(6))
                }
            }
        }
        describe("WKUIDelegate") {
            func createMiniAppView() -> MockRealMiniAppView {
                return MockRealMiniAppView(
                    miniAppId: "miniappid-testing",
                    versionId: "version-id",
                    projectId: "project-id",
                    miniAppTitle: "Mini app title",
                    hostAppMessageDelegate: MockMessageInterface())
            }
            context("when webview is loaded with alert javascript dialog") {
                it("will show native alert with request message") {
                    let miniAppView = createMiniAppView()
                    miniAppView.webView(miniAppView.webView, runJavaScriptAlertPanelWithMessage: "mini-app-alert",
                                        initiatedByFrame: WKFrameInfo(), completionHandler: {})

                    expect(miniAppView.alertController?.message).to(equal("mini-app-alert"))
                    expect(miniAppView.alertController?.actions[0].title).to(equal("OK"))
                    miniAppView.tapButton(.okButton)
                }
                it("will call completion handler when OK is tapped") {
                    var okTapped = false
                    let miniAppView = createMiniAppView()
                    miniAppView.webView(miniAppView.webView, runJavaScriptAlertPanelWithMessage: "mini-app-alert",
                                        initiatedByFrame: WKFrameInfo(), completionHandler: { okTapped = true })

                    miniAppView.tapButton(.okButton)
                    expect(okTapped).toEventually(beTrue())
                }
            }
            context("when webview is loaded with confirm javascript dialog") {
                it("will show native alert with request message, ok and cancel button") {
                    let miniAppView = createMiniAppView()
                    miniAppView.webView(miniAppView.webView, runJavaScriptConfirmPanelWithMessage: "mini-app-confirm",
                                        initiatedByFrame: WKFrameInfo(), completionHandler: {(_) in })

                    expect(miniAppView.alertController?.message).to(equal("mini-app-confirm"))
                    expect(miniAppView.alertController?.actions[0].title).to(equal("OK"))
                    expect(miniAppView.alertController?.actions[1].title).to(equal("Cancel"))
                }
                it("will return true to completion handler when OK button is tapped") {
                    var confirm = false
                    let miniAppView = createMiniAppView()
                    miniAppView.webView(miniAppView.webView, runJavaScriptConfirmPanelWithMessage: "mini-app-confirm",
                                        initiatedByFrame: WKFrameInfo(), completionHandler: {(status) in
                                            confirm = status
                                        })

                    miniAppView.tapButton(.okButton)
                    expect(confirm).toEventually(beTrue())
                }
                it("will show native alert with request message, ok and cancel button") {
                    let miniAppView = createMiniAppView()
                    miniAppView.webView(miniAppView.webView, runJavaScriptConfirmPanelWithMessage: "mini-app-confirm",
                                        initiatedByFrame: WKFrameInfo(), completionHandler: {(_) in })

                    expect(miniAppView.alertController).toEventuallyNot(beNil(), timeout: .seconds(10))
                    expect(miniAppView.alertController?.message).to(equal("mini-app-confirm"))
                    expect(miniAppView.alertController?.actions[0].title).to(equal("OK"))
                    expect(miniAppView.alertController?.actions[1].title).to(equal("Cancel"))
                }
                it("will return false to completion handler when Cancel button is tapped") {
                    var confirm = true
                    let miniAppView = createMiniAppView()
                    miniAppView.webView(miniAppView.webView, runJavaScriptConfirmPanelWithMessage: "mini-app-confirm",
                                        initiatedByFrame: WKFrameInfo(), completionHandler: {(status) in
                                            confirm = status
                                        })

                    miniAppView.tapButton(.cancelButton)
                    expect(confirm).toEventually(beFalse())
                }
            }
            context("when webview is loaded with prompt javascript dialog") {
                it("will show native alert with request message and wanted text in textfield") {
                    let miniAppView = createMiniAppView()
                    miniAppView.webView(miniAppView.webView, runJavaScriptTextInputPanelWithPrompt: "Please enter your name:",
                                        defaultText: "Rakuten Mini app", initiatedByFrame: WKFrameInfo(), completionHandler: {(_) in })

                    expect(miniAppView.alertController).toEventuallyNot(beNil(), timeout: .seconds(10))
                    expect(miniAppView.alertController?.actions[0].title).to(equal("OK"))
                    expect(miniAppView.alertController?.actions[1].title).to(equal("Cancel"))
                    expect(miniAppView.alertController?.message).to(equal("Please enter your name:"))
                    expect(miniAppView.alertController?.textFields?.first?.text).to(equal("Rakuten Mini app"))
                }
                it("will return text field value to completion hanlder when OK button is tapped") {
                    var userInput: String?
                    let miniAppView = createMiniAppView()
                    miniAppView.webView(miniAppView.webView, runJavaScriptTextInputPanelWithPrompt: "Please enter your name:",
                                        defaultText: "Rakuten Mini app", initiatedByFrame: WKFrameInfo(), completionHandler: {(value) in
                                            userInput = value
                                        })

                    miniAppView.tapButton(.okButton)
                    expect(userInput).toEventually(equal("Rakuten Mini app"))
                }
                it("will show native alert with request message and wanted no in textfield") {
                    let miniAppView = createMiniAppView()
                    miniAppView.webView(miniAppView.webView, runJavaScriptTextInputPanelWithPrompt: "Please enter your name:",
                                        defaultText: "", initiatedByFrame: WKFrameInfo(), completionHandler: {(_) in })

                    expect(miniAppView.alertController).toEventuallyNot(beNil(), timeout: .seconds(10))
                    expect(miniAppView.alertController?.actions[0].title).to(equal("OK"))
                    expect(miniAppView.alertController?.actions[1].title).to(equal("Cancel"))
                    expect(miniAppView.alertController?.message).to(equal("Please enter your name:"))
                    expect(miniAppView.alertController?.textFields?.first?.text).to(equal(""))
                }
                it("will return nil to completion handler when Cancel button is tapped") {
                    var userInput: String? = "fake-text"
                    let miniAppView = createMiniAppView()
                    miniAppView.webView(miniAppView.webView, runJavaScriptTextInputPanelWithPrompt: "Please enter your name:",
                                        defaultText: "", initiatedByFrame: WKFrameInfo(), completionHandler: {(value) in
                                            userInput = value
                                        })

                    miniAppView.tapButton(.cancelButton)
                    expect(userInput).toEventually(beNil())
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
