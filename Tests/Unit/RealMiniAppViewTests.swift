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
                                              miniAppTitle: "Mini app title",
                                              hostAppMessageDelegate: mockMessageInterface)
            context("when initialized with valid parameters") {
                it("will return MiniAppView object for given app id") {
                    let miniAppView = RealMiniAppView(miniAppId: "miniappid-testing",
                                                      versionId: "version-id",
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
                        miniAppTitle: "",
                        hostAppMessageDelegate: mockMessageInterface)
                    expect(miniAppView.webView.customUserAgent).toEventually(contain("MiniApp Demo App"), timeout: .seconds(6))
                }
            }
        }
        describe("WKUIDelegate") {
            let mockMessageInterface = MockMessageInterface()
            let miniAppView = MockRealMiniAppView(
                miniAppId: "miniappid-testing",
                versionId: "version-id",
                miniAppTitle: "Mini app title",
                hostAppMessageDelegate: mockMessageInterface)

            context("when webview is loaded with alert javascript dialog") {
                it("will show native alert with request message, ok with no crash") {
                    let html = """
                    <html>
                    <body>
                    <script>
                    alert("mini-app-alert")
                    </script>
                    </body>
                    </html>
                    """
                    miniAppView.webView.loadHTMLString(html, baseURL: nil)
                    expect(miniAppView.okText).toEventually(equal("OK"), timeout: .seconds(10))
                    expect(miniAppView.dialogMessage).toEventually(equal("mini-app-alert"), timeout: .seconds(10))
                    miniAppView.tapButton(.okButton)
                }
            }
        }
        describe("WKUIDelegate") {
            let mockMessageInterface = MockMessageInterface()
            let miniAppView = MockRealMiniAppView(
                miniAppId: "miniappid-testing",
                versionId: "version-id",
                miniAppTitle: "Mini app title",
                hostAppMessageDelegate: mockMessageInterface)
            context("when webview is loaded with confirm javascript dialog") {
                it("will show native alert with request message, ok and cancel button, ok don't crash") {
                    let html = """
                    <html>
                    <body>
                    <script>
                    confirm("mini-app-confirm")
                    </script>
                    </body>
                    </html>
                    """
                    miniAppView.webView.loadHTMLString(html, baseURL: nil)
                    expect(miniAppView.okText).toEventually(equal("OK"), timeout: .seconds(10))
                    expect(miniAppView.cancelText).toEventually(equal("Cancel"), timeout: .seconds(10))
                    expect(miniAppView.dialogMessage).toEventually(equal("mini-app-confirm"), timeout: .seconds(10))
                    miniAppView.tapButton(.okButton)
                }
            }
        }
        describe("WKUIDelegate") {
            let mockMessageInterface = MockMessageInterface()
            let miniAppView = MockRealMiniAppView(
                miniAppId: "miniappid-testing",
                versionId: "version-id",
                miniAppTitle: "Mini app title",
                hostAppMessageDelegate: mockMessageInterface)
            context("when webview is loaded with confirm javascript dialog") {
                it("will show native alert with request message, ok and cancel button, cancel don't crash") {
                    let html = """
                    <html>
                    <body>
                    <script>
                    confirm("mini-app-confirm")
                    </script>
                    </body>
                    </html>
                    """
                    miniAppView.webView.loadHTMLString(html, baseURL: nil)
                    expect(miniAppView.okText).toEventually(equal("OK"), timeout: .seconds(10))
                    expect(miniAppView.cancelText).toEventually(equal("Cancel"), timeout: .seconds(10))
                    expect(miniAppView.dialogMessage).toEventually(equal("mini-app-confirm"), timeout: .seconds(10))
                    miniAppView.tapButton(.cancelButton)
                }
            }
        }
        describe("WKUIDelegate") {
                let mockMessageInterface = MockMessageInterface()
                let miniAppView = MockRealMiniAppView(
                    miniAppId: "miniappid-testing",
                    versionId: "version-id",
                    miniAppTitle: "Mini app title",
                    hostAppMessageDelegate: mockMessageInterface)
            context("when webview is loaded with prompt javascript dialog") {
                it("will show native alert with request message and wanted text in textfield, ok will transmit text with no crash") {
                    let html = """
                    <html>
                    <body>
                    <script>
                    prompt("Please enter your name:", "Rakuten Mini app");
                    </script>
                    </body>
                    </html>
                    """
                    miniAppView.webView.loadHTMLString(html, baseURL: nil)
                    expect(miniAppView.okText).toEventually(equal("OK"), timeout: .seconds(10))
                    expect(miniAppView.cancelText).toEventually(equal("Cancel"), timeout: .seconds(10))
                    expect(miniAppView.dialogMessage).toEventually(equal("Please enter your name:"), timeout: .seconds(10))
                    expect(miniAppView.dialogTextFieldText).toEventually(equal("Rakuten Mini app"), timeout: .seconds(10))
                    miniAppView.tapButton(.okButton)
                }
            }
            describe("WKUIDelegate") {
                let mockMessageInterface = MockMessageInterface()
                let miniAppView = MockRealMiniAppView(
                    miniAppId: "miniappid-testing",
                    versionId: "version-id",
                    miniAppTitle: "Mini app title",
                    hostAppMessageDelegate: mockMessageInterface)
                context("when webview is loaded with prompt javascript dialog") {
                    it("will show native alert with request message and wanted no in textfield, cancel won't crash") {
                        let html = """
                    <html>
                    <body>
                    <script>
                    prompt("Please enter your name:", "");
                    </script>
                    </body>
                    </html>
                    """
                        miniAppView.webView.loadHTMLString(html, baseURL: nil)
                        expect(miniAppView.okText).toEventually(equal("OK"), timeout: .seconds(10))
                        expect(miniAppView.cancelText).toEventually(equal("Cancel"), timeout: .seconds(10))
                        expect(miniAppView.dialogMessage).toEventually(equal("Please enter your name:"), timeout: .seconds(10))
                        expect(miniAppView.dialogTextFieldText).toEventually(equal(""), timeout: .seconds(10))
                        miniAppView.tapButton(.cancelButton)
                    }
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
                        versionId: "version-id", miniAppTitle: "",
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
                        miniAppId: "miniappid-testing", versionId: "version-id", miniAppTitle: "",
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
                        miniAppId: "miniappid-testing", versionId: "version-id", miniAppTitle: "", hostAppMessageDelegate: mockMessageInterface,
                        displayNavBar: .always,
                        navigationDelegate: customNav,
                        navigationView: customNav
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
                        miniAppId: "miniappid-testing", versionId: "version-id", miniAppTitle: "",
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
