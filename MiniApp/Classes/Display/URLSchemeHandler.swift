import WebKit

/// This class helps to handle Custom URL schemes that is Registered in MiniAppWebView class
class URLSchemeHandler : NSObject, WKURLSchemeHandler {

    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let loadRequestUrl = webView.url else { return }

        if urlSchemeTask.request.url != nil {
            do {
                guard let miniAppFilePath = getMiniAppFilePath(webViewRequestUrl: loadRequestUrl, schemeRequestUrl: urlSchemeTask.request.url?.absoluteURL) else {
                    return
                }
                let data = try Data(contentsOf: miniAppFilePath)
                urlSchemeTask.didReceive(URLResponse(url: urlSchemeTask.request.url!, mimeType: "text/html", expectedContentLength: data.count, textEncodingName: nil))
                urlSchemeTask.didReceive(data)
                urlSchemeTask.didFinish()
            } catch let error as NSError {
                print("Error: ",error)
            }
        }
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
    }

    /// Returns Mini app id from a given scheme
    ///
    /// For eg., If miniapp.MINI_APP_ID is the scheme, this method returns only MINI_APP_ID
    /// - Parameter scheme: Scheme that is requested to load in the WebView instance
    func getAppIdFromScheme(scheme: String) -> String {
        return scheme.replacingOccurrences(of: Constants.miniAppSchemePrefix, with: "")
    }

    /// Returns file path from the Mini App folder for a requested URL
    /// - Parameter url: Custom URL scheme that is loaded as URLRequest in WebView
    func getMiniAppFilePath(webViewRequestUrl: URL, schemeRequestUrl: URL?) -> URL? {
        guard let scheme = schemeRequestUrl?.scheme else {
            return nil
        }
        let urlSchemeSeparator = scheme + "://"
        let miniAppPath = FileManager.getMiniAppVersionDirectory(usingAppId: getAppIdFromScheme(scheme: scheme))

        // Only for the first time, webViewRequestUrl and schemeRequestUrl will be same when index.html is loaded.
        // webViewRequestUrl & schemeRequestUrl - miniapp.MINI_APP_ID://index.html
        // For the subsequent request, webViewRequestUrl will remain the same but schemeRequestUrl will be for respective local files inside mini app folder
        if(webViewRequestUrl == schemeRequestUrl) {
            guard let queryParameter = schemeRequestUrl?.absoluteString.replacingOccurrences(of: urlSchemeSeparator, with: "") else {
                return nil
            }
            return miniAppPath?.appendingPathComponent(queryParameter)
        } else {
            guard let queryParameter = schemeRequestUrl?.absoluteString.replacingOccurrences(of: webViewRequestUrl.absoluteString, with: "") else {
                return nil
            }
            return miniAppPath?.appendingPathComponent(queryParameter)
        }
    }
}
