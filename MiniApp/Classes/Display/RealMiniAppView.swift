import WebKit

internal class RealMiniAppView: UIView {

    internal var webView: WKWebView
    internal var navBar: (UIView & MiniAppNavigationDelegate)?
    internal weak var hostAppMessageDelegate: MiniAppMessageProtocol?
    internal weak var navigationDelegate: MiniAppNavigationDelegate?
    private var webViewBottomConstraintStandalone: NSLayoutConstraint?
    private var wevViewBottonConstraintWithNavBar: NSLayoutConstraint?
    private var navBarVisibility: MiniAppNavigationVisibility

    init(miniAppId: String, versionId: String, hostAppMessageDelegate: MiniAppMessageProtocol, displayNavBar: MiniAppNavigationVisibility = .auto, navigationDelegate: MiniAppNavigationDelegate? = nil, navigationView: (UIView & MiniAppNavigationDelegate)? = nil) {
        webView = MiniAppWebView(miniAppId: miniAppId, versionId: versionId)
        self.hostAppMessageDelegate = hostAppMessageDelegate
        navBarVisibility = displayNavBar
        super.init(frame: .zero)

        if navigationView == nil, navBarVisibility != .never {
            webView.navigationDelegate = self
            navBar = MiniAppNavigationBar(frame: .zero, delegate: self)
        } else {
            navBar = navigationView
        }
        webView.configuration.userContentController.addMiniAppScriptMessageHandler(delegate: self, hostAppMessageDelegate: hostAppMessageDelegate)
        webView.configuration.userContentController.addBridgingJavaScript()
        webView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        self.navigationDelegate = navigationDelegate
        addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.layoutAttachTop()
        webViewBottomConstraintStandalone = webView.layoutAttachBottom()
        webView.layoutAttachLeading()
        webView.layoutAttachTrailing()
        wevViewBottonConstraintWithNavBar = navBar?.layoutAttachTop(to: webView)
        webViewBottomConstraintStandalone?.isActive = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "loading") {
            MiniAppLogger.d("loading")
        }
    }

    func refreshNavBar() {
        var actionsAvailable = [MiniAppNavigationAction]()
        if webView.canGoBack || navBarVisibility == .always {
            actionsAvailable.append(.back)
        }
        if webView.canGoForward || navBarVisibility == .always {
            actionsAvailable.append(.forward)
        }
        navigationDelegate?.miniAppNavigation(canUse: actionsAvailable)
        if actionsAvailable.count == 0 && navBarVisibility != .never {
            webView.constraints.forEach { c in
                if (c.firstItem as? UIView == webView || c.secondItem as? UIView == navBar) {
                    webView.removeConstraint(c)
                }
            }
            webViewBottomConstraintStandalone?.isActive = navBarVisibility == .auto
            wevViewBottonConstraintWithNavBar?.isActive = navBarVisibility == .always
            navBar?.removeFromSuperview()
        } else {
            if let nav = navBar {
                let navDelegate = navigationDelegate as? UIView
                if navDelegate == nil || navDelegate != nav {
                    nav.miniAppNavigation(canUse: actionsAvailable)
                }

                if navBarVisibility != .never {
                    addSubview(nav)
                    nav.translatesAutoresizingMaskIntoConstraints = false
                    webViewBottomConstraintStandalone?.isActive = navBarVisibility == .always
                    wevViewBottonConstraintWithNavBar?.isActive = navBarVisibility == .auto
                    nav.layoutAttachBottom()
                    nav.layoutAttachLeading()
                    nav.layoutAttachTrailing()
                }
            }
        }
    }

    deinit {
        webView.configuration.userContentController.removeMessageHandler()
    }
}

extension RealMiniAppView: MiniAppDisplayProtocol {
    public func getMiniAppView() -> UIView {
        return self
    }
}

extension RealMiniAppView: MiniAppCallbackProtocol {
    func didReceiveScriptMessageResponse(messageId: String, response: String) {
        self.webView.evaluateJavaScript(Constants.javascriptSuccessCallback + "('\(messageId)'," + "'\(response)')")
    }

    func didReceiveScriptMessageError(messageId: String, errorMessage: String) {
        self.webView.evaluateJavaScript(Constants.javascriptErrorCallback + "('\(messageId)'," + "'\(errorMessage)')")
    }
}

extension RealMiniAppView: MiniAppNavigationBarDelegate {
    func miniAppNavigationBar(_ miniApp: MiniAppNavigationBar, didTriggerAction action: MiniAppNavigationAction) {
        switch action {
        case .back:
            if (self.webView.canGoBack) {
                self.webView.goBack()
            }
        case .forward:
            if (self.webView.canGoForward) {
                self.webView.goForward()
            }
        }
        refreshNavBar()
    }
}

extension RealMiniAppView: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        refreshNavBar()
    }
}
