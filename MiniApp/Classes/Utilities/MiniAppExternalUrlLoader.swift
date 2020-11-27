import WebKit

public class MiniAppExternalUrlLoader {
    public weak var currentWebViewController: UIViewController?
    public var currentResponseHandler: MiniAppNavigationResponseHandler?
    public var customMiniAppURL: URL?

    /// This class supports the scenario that external loader redirects url that are only supported in mini app view,
    /// closes the external loader and emits that url to mini app view with the help of  a MiniAppNavigationResponseHandler.
    ///
    /// - Parameters:
    ///     -   webViewController: The UIViewController containing the external webview.
    ///         Provide it if you want the controller to auto-close when a Mini App url is triggered.
    ///     -   responseHandler: a MiniAppNavigationResponseHandler closure that will provide the Mini App view the url that has been triggered.
    ///     -   customMiniAppURL: The url that was used to load the Mini App.
    ///         Provide this if you want to manage the result of the external navigation inside your Mini App
    public init(webViewController: UIViewController? = nil,
                responseHandler: MiniAppNavigationResponseHandler? = nil,
                customMiniAppURL: URL? = nil) {
        currentWebViewController = webViewController
        currentResponseHandler = responseHandler
        self.customMiniAppURL = customMiniAppURL
    }

    /// Use this method inside your WKNavigationDelegate to provide the appropriate WKNavigationActionPolicy to the decidePolicyForNavigationAction method,
    /// and eventually close the external webview controller if a Mini App link is triggered
    /// and provide a feedback to the Mini App via the MiniAppNavigationResponseHandler
    public func shouldOverrideURLLoading(_ url: URL?) -> WKNavigationActionPolicy {
        MiniAppLogger.d("shouldOverrideURLLoading(_ url: \(url?.absoluteString ?? "?"))")
        if let urlWebview = url, urlWebview.isMiniAppURL(customMiniAppURL: customMiniAppURL) {
            self.currentResponseHandler?(urlWebview)
            self.currentWebViewController?.dismiss(animated: true)
            return .cancel
        } else {
            return validateScheme(url: url)
        }
    }

    private func validateScheme(url: URL?) -> WKNavigationActionPolicy {
        guard let requestURL = url, let scheme = requestURL.scheme, let schemeType = MiniAppSupportedSchemes(rawValue: scheme) else {
            return .allow
        }
        switch schemeType {
        case .tel:
            UIApplication.shared.open(requestURL, options: [:], completionHandler: nil)
        default:
            return .cancel
        }
        return .cancel
    }
}
