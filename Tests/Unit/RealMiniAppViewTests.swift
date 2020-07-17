import Quick
import Nimble
@testable import MiniApp
@testable import WebKit

// swiftlint:disable function_body_length
class RealMiniAppViewTests: QuickSpec {
    override func spec() {
        describe("Mini App view") {
            let mockMessageInterface = MockMessageInterface()
            let miniAppView = RealMiniAppView(miniAppId: "miniappid-testing", versionId: "version-id", miniAppTitle: "Mini app title", hostAppMessageDelegate: mockMessageInterface)

            context("when initialized with valid parameters") {
                it("will return MiniAppView object") {
                    let miniAppView = RealMiniAppView(miniAppId: "miniappid-testing", versionId: "version-id", hostAppMessageDelegate: mockMessageInterface)
                    expect(miniAppView).toEventually(beAnInstanceOf(RealMiniAppView.self))
                }
            }
            context("when getMiniAppView is called") {
                it("will return object of UIView type") {
                    expect(miniAppView.getMiniAppView()).toEventually(beAKindOf(UIView.self))
                }
            }
            context("when RealMiniAppView is called with coder") {
                it("will return nil") {
                    let keyedArchiver = NSKeyedArchiver()
                    let realMiniAppView = RealMiniAppView(coder: keyedArchiver)
                    expect(realMiniAppView).toEventually(beNil())
                }
            }
        }
        describe("WKUIDelegate") {
            let mockMessageInterface = MockMessageInterface()
            let miniAppView = RealMiniAppView(miniAppId: "miniappid-testing", versionId: "version-id", miniAppTitle: "Mini app title", hostAppMessageDelegate: mockMessageInterface)

            context("when webview is loaded with alert javascript dialog") {
                it("will show native alert with request message") {
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
                    var alertMessage: String = ""
                    var alert: UIAlertController?
                    miniAppView.webView.loadHTMLString(html, baseURL: nil)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 6.0, execute: {
                        alert =  UIApplication.topViewController() as? UIAlertController
                        alertMessage = alert?.message ?? ""
                        expect(alert?.actions.map({ $0.title })).to(equal(["OK"]))
                    })
                    expect(alertMessage).toEventually(equal("mini-app-alert"), timeout: 10)
                    tapAlertButton(title: "OK", actions: alert?.actions ?? nil)
                }
            }
        }
        describe("WKUIDelegate") {
            let mockMessageInterface = MockMessageInterface()
            let miniAppView = RealMiniAppView(miniAppId: "miniappid-testing", versionId: "version-id", miniAppTitle: "Mini app title", hostAppMessageDelegate: mockMessageInterface)
            context("when webview is loaded with confirm javascript dialog") {
                it("will show native alert with request message and ok button is tapped") {
                    let html = """
                    <html>
                    <body>
                    <script>
                    confirm("mini-app-confirm")
                    </script>
                    </body>
                    </html>
                    """
                    var alertMessage: String = ""
                    var alert: UIAlertController?
                    DispatchQueue.main.asyncAfter(deadline: .now() + 8.0, execute: {
                        miniAppView.webView.loadHTMLString(html, baseURL: nil)
                    })
                    DispatchQueue.main.asyncAfter(deadline: .now() + 9.0, execute: {
                        alert =  UIApplication.topViewController() as? UIAlertController
                        alertMessage = alert?.message ?? ""
                        expect(alert?.actions.map({ $0.title })).to(equal(["OK", "Cancel"]))
                    })
                    expect(alertMessage).toEventually(equal("mini-app-confirm"), timeout: 20)
                    tapAlertButton(title: "OK", actions: alert?.actions ?? nil)
                }
            }
            context("when webview is loaded with confirm javascript dialog") {
                it("will show native alert with request message and cancel button is tapped") {
                    let html = """
                    <html>
                    <body>
                    <script>
                    confirm("mini-app-confirm")
                    </script>
                    </body>
                    </html>
                    """
                    var alertMessage: String = ""
                    var alert: UIAlertController?
                    DispatchQueue.main.asyncAfter(deadline: .now() + 11.0, execute: {
                        miniAppView.webView.loadHTMLString(html, baseURL: nil)
                    })
                    DispatchQueue.main.asyncAfter(deadline: .now() + 12.0, execute: {
                        alert =  UIApplication.topViewController() as? UIAlertController
                        alertMessage = alert?.message ?? ""
                        expect(alert?.actions.map({ $0.title })).to(equal(["OK", "Cancel"]))
                    })
                    expect(alertMessage).toEventually(equal("mini-app-confirm"), timeout: 20)
                    tapAlertButton(title: "Cancel", actions: alert?.actions ?? nil)
                }
            }
        }
        describe("WKUIDelegate") {
                let mockMessageInterface = MockMessageInterface()
                let miniAppView = RealMiniAppView(miniAppId: "miniappid-testing", versionId: "version-id", miniAppTitle: "Mini app title", hostAppMessageDelegate: mockMessageInterface)
            context("when webview is loaded with prompt javascript dialog") {
                it("will show native alert with request message and cancel button is tapped") {
                    let html = """
                    <html>
                    <body>
                    <script>
                    prompt("Please enter your name:", "Rakuten Mini app");
                    </script>
                    </body>
                    </html>
                    """
                    var alertMessage: String = ""
                    var alert: UIAlertController?
                    DispatchQueue.main.asyncAfter(deadline: .now() + 14.0, execute: {
                        miniAppView.webView.loadHTMLString(html, baseURL: nil)
                    })
                    DispatchQueue.main.asyncAfter(deadline: .now() + 16.0, execute: {
                        alert =  UIApplication.topViewController() as? UIAlertController
                        alertMessage = alert?.message ?? ""
                        expect(alert?.actions.map({ $0.title })).to(equal(["OK", "Cancel"]))
                    })
                    expect(alertMessage).toEventually(equal("Please enter your name:"), timeout: 20)
                    tapAlertButton(title: "Cancel", actions: alert?.actions ?? nil)
                }
            }
            context("when webview is loaded with prompt javascript dialog") {
                it("will show native alert with request message and Ok button is tapped") {
                    let html = """
                    <html>
                    <body>
                    <script>
                    prompt("Please enter your name:", "Rakuten Mini app");
                    </script>
                    </body>
                    </html>
                    """
                    var alertMessage: String = ""
                    var alert: UIAlertController?
                    DispatchQueue.main.asyncAfter(deadline: .now() + 17.0, execute: {
                        miniAppView.webView.loadHTMLString(html, baseURL: nil)
                    })
                    DispatchQueue.main.asyncAfter(deadline: .now() + 18.0, execute: {
                        alert =  UIApplication.topViewController() as? UIAlertController
                        alertMessage = alert?.message ?? ""
                        expect(alert?.actions.map({ $0.title })).to(equal(["OK", "Cancel"]))
                    })
                    expect(alertMessage).toEventually(equal("Please enter your name:"), timeout: 20)
                    tapAlertButton(title: "OK", actions: alert?.actions ?? nil)
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
