import WebKit

public class MiniAppExternalUrlLoader {
    public var currentWebViewController: UIViewController?
    public var currentResponseHandler: MiniAppNavigationResponseHandler?

    /// This class supports the scenario that external loader redirects url that are only supported in mini app view,
    /// closes the external loader and emits that url to mini app view with the help of  a MiniAppNavigationResponseHandler.
    ///
    /// - Parameters:
    ///     -   webViewController: The UIViewController containing the external webview.
    ///         Provide it if you want the controller to auto-close when a Mini App url is triggered.
    ///     -   responseHandler: a MiniAppNavigationResponseHandler closure that will provide the Mini App view the url that has been triggered.
    ///         Provide this if you want to manage the result of the external navigation inside your Mini App
    public init(webViewController: UIViewController? = nil, responseHandler: MiniAppNavigationResponseHandler? = nil) {
        currentWebViewController = webViewController
        currentResponseHandler = responseHandler
    }

    /// Use this method inside your WKNavigationDelegate to provide the appropriate WKNavigationActionPolicy to the decidePolicyForNavigationAction method,
    /// and eventually close the external webview controller if a Mini App link is triggered
    /// and provide a feedback to the Mini App via the MiniAppNavigationResponseHandler
    public func shouldOverrideURLLoading(_ url: URL?) -> WKNavigationActionPolicy {
        if let urlWebview = url, urlWebview.isMiniAppURL() {
            self.currentResponseHandler?(urlWebview)
            self.currentWebViewController?.dismiss(animated: true)
            return .cancel
        } else {
            return .allow
        }
    }
}
