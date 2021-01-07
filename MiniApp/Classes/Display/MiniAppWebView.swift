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

    convenience init(miniAppId: String, versionId: String, queryParams: String? = nil) {
        let schemeName = Constants.miniAppSchemePrefix + miniAppId
        let urlRequest = URLRequest(url: URL(string: schemeName + "://miniapp/" + Constants.rootFileName + MiniAppWebView.getQueryParams(queryParams: queryParams))!)
        let config = MiniAppWebView.defaultConfig()
        config.setURLSchemeHandler(URLSchemeHandler(versionId: versionId), forURLScheme: schemeName)
        self.init(frame: .zero, configuration: config)
        commonInit(urlRequest: urlRequest)
    }

    convenience init(miniAppURL: URL, queryParams: String? = nil) {
        let urlRequest = URLRequest(url: miniAppURL)
        self.init(frame: .zero, configuration: MiniAppWebView.defaultConfig())
        commonInit(urlRequest: urlRequest)
    }

    private static func getQueryParams(queryParams: String?) -> String {
        guard let param = queryParams, let queryString =  param.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return ""
        }
        return "?" + queryString
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
