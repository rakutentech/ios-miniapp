import WebKit

internal class MiniAppWebView: WKWebView {

    convenience init?(miniAppId: String) {
        let schemeName = Constants.miniAppSchemePrefix + miniAppId
        let urlRequest = URLRequest(url: URL(string: schemeName + "://miniapp/" + Constants.rootFileName)!)
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        config.setURLSchemeHandler(URLSchemeHandler(), forURLScheme: schemeName)
        self.init(frame: .zero, configuration: config)
        contentMode = .scaleToFill
        load(urlRequest)
    }
}
