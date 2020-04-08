import WebKit

public class RealMiniAppView: UIView, MiniAppDisplayProtocol {

    private var webView: WKWebView

    init?(miniAppId: String, messageInterface: MiniAppMessageProtocol) {
        guard let miniAppWebView = MiniAppWebView(miniAppId: miniAppId) else {
            return nil
        }
        webView = miniAppWebView
        super.init(frame: .zero)
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
