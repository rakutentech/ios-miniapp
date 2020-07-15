import Quick
import Nimble
@testable import MiniApp

// swiftlint:disable function_body_length
class RealMiniAppViewTests: QuickSpec {

    override func spec() {
        describe("Mini App view") {
            let mockMessageInterface = MockMessageInterface()
            let miniAppView = RealMiniAppView(miniAppId: "miniappid-testing", versionId: "version-id", miniAppTitle: "Mini app title", hostAppMessageDelegate: mockMessageInterface)

            context("when initialized with valid parameters") {
                it("will return MiniAppView object") {
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
