import WebKit

internal class MiniAppWebView: WKWebView {

    static let schemePrefixName = "miniapp"

    convenience init?(miniAppId: String) {
        let schemeName = Constants.miniAppSchemePrefix + miniAppId
        let urlRequest = URLRequest(url: URL(string: schemeName + "://index.html")!)
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        config.setURLSchemeHandler(URLSchemeHandler(), forURLScheme: schemeName)
        self.init(frame: .zero, configuration: config)
        contentMode = .scaleToFill
        load(urlRequest)
    }
}
