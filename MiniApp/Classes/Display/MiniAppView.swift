import WebKit

public class MiniAppView: UIView {
    private var webView: WKWebView

    init(filePath: URL) {
        webView = MiniAppWebView(filePath: filePath)
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
}
