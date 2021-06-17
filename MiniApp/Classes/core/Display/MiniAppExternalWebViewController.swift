import Foundation
import UIKit
import WebKit

class MiniAppExternalWebViewController: UIViewController {

    private var webView: WKWebView!
    private var currentURL: URL?
    private var customMiniAppURL: URL?
    private var miniAppExternalUrlLoader: MiniAppExternalUrlLoader?

    ///
    /// Presents a webview modally to handle external URLs.
    ///
    /// - Parameters:
    ///   - url: A url to load in a webview
    ///   - externalLinkResponseHandler: A closure that will provide triggered url to the Mini App view.
    ///   - customMiniAppURL: The url that was used to load the Mini App.
    ///
    public class func presentModally(url: URL,
                                     externalLinkResponseHandler: MiniAppNavigationResponseHandler?,
                                     customMiniAppURL: URL? = nil) {
        let webctrl = MiniAppExternalWebViewController()
        webctrl.currentURL = url
        webctrl.customMiniAppURL = customMiniAppURL
        let navigationController = MiniAppCloseNavigationController(rootViewController: webctrl)
        let closeButton = UIBarButtonItem(barButtonSystemItem: .done, target: navigationController, action: #selector(MiniAppCloseNavigationController.close))
        webctrl.navigationItem.rightBarButtonItem = closeButton
        webctrl.miniAppExternalUrlLoader = MiniAppExternalUrlLoader(webViewController: webctrl,
                                                                    responseHandler: externalLinkResponseHandler,
                                                                    customMiniAppURL: customMiniAppURL)
        UIApplication.shared.keyWindow()?.topController()?.present(navigationController, animated: true)
    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = .lightGray

        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        config.allowsInlineMediaPlayback = true
        config.allowsPictureInPictureMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        self.webView = WKWebView(frame: self.view.frame, configuration: config)
        self.webView.allowsBackForwardNavigationGestures = true
        self.view.addSubview(self.webView)
        self.webView.translatesAutoresizingMaskIntoConstraints = true
        self.webView.frame = view.bounds
        self.webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.webView.navigationDelegate = self
        if let url = currentURL {
            self.webView.load(URLRequest(url: url))
        }
    }
}

extension MiniAppExternalWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.currentURL = self.webView.url
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let navigationTypes: [WKNavigationType] = [.linkActivated, .formSubmitted]
        if navigationTypes.contains(navigationAction.navigationType) {
            if !(navigationAction.targetFrame?.isMainFrame ?? false) {
                decisionHandler(.cancel)
                self.webView.load(navigationAction.request)
            } else {
                decisionHandler(miniAppExternalUrlLoader?.shouldOverrideURLLoading(navigationAction.request.url) ?? .allow)
            }
        } else {
            decisionHandler(.allow)
        }
    }
}

internal class MiniAppCloseNavigationController: UINavigationController {
    @objc public func close() {
        self.dismiss(animated: true)
    }
}
