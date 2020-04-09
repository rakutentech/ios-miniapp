import WebKit

public class MiniAppView: UIView, MiniAppDisplayProtocol {

    private var webView: WKWebView

    init?(miniAppId: String, messageInterface: MiniAppMessageProtocol) {
        guard let miniAppWebView = MiniAppWebView(miniAppId: miniAppId) else {
            return nil
        }
        webView = miniAppWebView
        super.init(frame: .zero)
        webView.configuration.userContentController.add(self, name: Constants.javascriptInterface)
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
}

extension MiniAppView: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let messageBody = message.body as? [String: Any] {
            // Message that is sent from the Javascript
            // We need to parse this message and call appropriate method
        }
    }
}
