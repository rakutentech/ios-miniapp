import WebKit

internal class MiniAppWebView: WKWebView {

    private static func defaultConfig() -> WKWebViewConfiguration {
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.allowsPictureInPictureMediaPlayback = true
        return config
    }

    convenience init(miniAppId: String, versionId: String) {
        let schemeName = Constants.miniAppSchemePrefix + miniAppId
        let urlRequest = URLRequest(url: URL(string: schemeName + "://miniapp/" + Constants.rootFileName)!)
        let config = MiniAppWebView.defaultConfig()
        config.setURLSchemeHandler(URLSchemeHandler(versionId: versionId), forURLScheme: schemeName)
        self.init(frame: .zero, configuration: config)
        commonInit(urlRequest: urlRequest)
    }

    convenience init(miniAppURL: URL) {
        let urlRequest = URLRequest(url: miniAppURL.appendingPathComponent(Constants.rootFileName))
        self.init(frame: .zero, configuration: MiniAppWebView.defaultConfig())
        commonInit(urlRequest: urlRequest)
    }

    private func commonInit(urlRequest: URLRequest) {
        let environment = Environment()
        self.allowsBackForwardNavigationGestures = true
        contentMode = .scaleToFill
        load(urlRequest)

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
