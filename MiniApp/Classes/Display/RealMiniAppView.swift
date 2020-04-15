import WebKit

public class RealMiniAppView: UIView, MiniAppDisplayProtocol, MiniAppCallbackProtocol {
    internal var webView: WKWebView
    private var hostAppMessageDelegate: MiniAppMessageProtocol

    init?(miniAppId: String, hostAppMessageDelegate: MiniAppMessageProtocol) {
        guard let miniAppWebView = MiniAppWebView(miniAppId: miniAppId) else {
            return nil
        }
        webView = miniAppWebView
        self.hostAppMessageDelegate = hostAppMessageDelegate
        super.init(frame: .zero)
        webView.configuration.userContentController.addMiniAppScriptMessageHandler(delegate: self, hostAppMessageDelegate: hostAppMessageDelegate)
        webView.configuration.userContentController.addBridgingJavaScript()
        addSubview(webView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        webView.frame = bounds
    }

    public func getMiniAppView() -> UIView {
        return self
    }

    func didRecieveScriptMessageResponse(messageId: String, response: String) {
        self.webView.evaluateJavaScript(Constants.javascriptSuccessCallback + "('\(messageId)'," + "'\(response)')")
    }

    func didRecieveScriptMessageError(messageId: String, errorMessage: String) {
        self.webView.evaluateJavaScript(Constants.javascriptErrorCallback + "('\(messageId)'," + "'\(errorMessage)')")
    }

    deinit {
        webView.configuration.userContentController.removeMessageHandler()
    }
}
