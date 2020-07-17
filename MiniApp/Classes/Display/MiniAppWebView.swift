import WebKit

internal class MiniAppWebView: WKWebView {

    convenience init() {
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        self.init(frame: .zero, configuration: config)
        self.allowsBackForwardNavigationGestures = true
        contentMode = .scaleToFill
        if !environment.hostAppUserAgentInfo.isEmpty && environment.hostAppUserAgentInfo != "NONE" {
            evaluateJavaScript("navigator.userAgent") { [weak self] (result, error) in
                if error != nil {
                    return
                }
                if let userAgent = result as? String {
                    self?.customUserAgent = userAgent + " " + environment.hostAppUserAgentInfo
                }
            }
        }
    }
}
