import WebKit

internal class MiniAppWebView: WKWebView {

    convenience init(miniAppId: String, versionId: String) {
        let environment = Environment()
        let schemeName = Constants.miniAppSchemePrefix + miniAppId
        let urlRequest = URLRequest(url: URL(string: schemeName + "://miniapp/" + Constants.rootFileName)!)
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        config.setURLSchemeHandler(URLSchemeHandler(versionId: versionId), forURLScheme: schemeName)
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.allowsPictureInPictureMediaPlayback = true
        self.init(frame: .zero, configuration: config)
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
