import WebKit

internal class MiniAppWebView: WKWebView {

    convenience init() {
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        self.init(frame: .zero, configuration: config)
        self.allowsBackForwardNavigationGestures = true
        contentMode = .scaleToFill
    }
}
