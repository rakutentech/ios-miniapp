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
        let config = MiniAppWebView.defaultConfig()
        config.setURLSchemeHandler(URLSchemeHandler(versionId: versionId), forURLScheme: schemeName)
        self.init(frame: .zero, configuration: config)
        commonInit(urlRequest: Self.getURLRequest(miniAppId: miniAppId, schemeName: schemeName, queryParams: queryParams))
    }

    convenience init(miniAppURL: URL, queryParams: String? = nil) {
        let urlRequest = URLRequest(url: Self.getURL(miniAppURL: miniAppURL, queryParams: queryParams))
        self.init(frame: .zero, configuration: MiniAppWebView.defaultConfig())
        commonInit(urlRequest: urlRequest)
    }

    private static func getURL(miniAppURL: URL, queryParams: String?) -> URL {
        guard let urlWithQueryParam = miniAppURL.appendingPathComponent(Self.getQueryParams(queryParams: queryParams)).absoluteString.removingPercentEncoding else {
            return miniAppURL
        }

        return URL(string: urlWithQueryParam)!
    }

    private static func getURLRequest(miniAppId: String, schemeName: String, queryParams: String?) -> URLRequest {
        guard let url = URL(string: schemeName + "://miniapp/" + Constants.rootFileName + MiniAppWebView.getQueryParams(queryParams: queryParams)) else {
            return URLRequest(url: URL(string: schemeName + "://miniapp/" + Constants.rootFileName)!)
        }
        return URLRequest(url: url)
    }

    private static func getQueryParams(queryParams: String?) -> String {
        guard let paramsString = queryParams, !paramsString.isEmpty else {
            return ""
        }
        return "?" + paramsString.replacingOccurrences(of: " ", with: "%20")
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
