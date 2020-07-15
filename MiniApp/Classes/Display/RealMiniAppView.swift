import WebKit

internal class RealMiniAppView: UIView, MiniAppDisplayProtocol, MiniAppCallbackProtocol {
    internal var webView: WKWebView
    internal weak var hostAppMessageDelegate: MiniAppMessageProtocol?
    internal var miniAppTitle: String

    init(miniAppId: String, versionId: String, miniAppTitle: String, hostAppMessageDelegate: MiniAppMessageProtocol) {
        self.miniAppTitle = miniAppTitle
        webView = MiniAppWebView(miniAppId: miniAppId, versionId: versionId)
        self.hostAppMessageDelegate = hostAppMessageDelegate
        super.init(frame: .zero)
        webView.configuration.userContentController.addMiniAppScriptMessageHandler(delegate: self, hostAppMessageDelegate: hostAppMessageDelegate)
        webView.configuration.userContentController.addBridgingJavaScript()
        webView.uiDelegate = self
        addSubview(webView)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        webView.frame = bounds
    }

    public func getMiniAppView() -> UIView {
        return self
    }

    func didReceiveScriptMessageResponse(messageId: String, response: String) {
        self.webView.evaluateJavaScript(Constants.javascriptSuccessCallback + "('\(messageId)'," + "'\(response)')")
    }

    func didReceiveScriptMessageError(messageId: String, errorMessage: String) {
        self.webView.evaluateJavaScript(Constants.javascriptErrorCallback + "('\(messageId)'," + "'\(errorMessage)')")
    }

    deinit {
        webView.configuration.userContentController.removeMessageHandler()
    }
}
