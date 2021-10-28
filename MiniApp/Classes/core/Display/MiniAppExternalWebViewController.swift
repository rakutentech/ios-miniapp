import Foundation
import UIKit
import WebKit

public class MiniAppExternalWebViewController: UIViewController {

    private var webView: WKWebView!
    private var currentURL: URL?
    private var customMiniAppURL: URL?
    private var miniAppExternalUrlLoader: MiniAppExternalUrlLoader?
    private var miniAppExternalUrlClose: MiniAppNavigationResponseHandler?

    lazy var backBarButton: UIBarButtonItem = {
        let view = UIBarButtonItem(image: UIImage(named: "arrow_left-24", in: Bundle.miniAppSDKBundle(), with: .none), style: .plain, target: self, action: #selector(navigateBack))
        view.isEnabled = false
        return view
    }()
    lazy var forwardBarButton: UIBarButtonItem = {
        let view = UIBarButtonItem(image: UIImage(named: "arrow_right-24", in: Bundle.miniAppSDKBundle(), with: .none), style: .plain, target: self, action: #selector(navigateForward))
        view.isEnabled = false
        return view
    }()

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
                                     customMiniAppURL: URL? = nil,
                                     onCloseHandler: MiniAppNavigationResponseHandler?) {
        let webctrl = MiniAppExternalWebViewController()
        webctrl.miniAppExternalUrlClose = onCloseHandler
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

    public override func loadView() {
        view = UIView()
        view.backgroundColor = .lightGray
        self.webView = WKWebView(frame: self.view.frame, configuration: getWebViewConfig())
        self.webView.allowsBackForwardNavigationGestures = true
        self.view.addSubview(self.webView)
        self.webView.translatesAutoresizingMaskIntoConstraints = true
        self.webView.frame = view.bounds
        self.webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    func getWebViewConfig() -> WKWebViewConfiguration {
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        config.allowsInlineMediaPlayback = true
        config.allowsPictureInPictureMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        return config
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.webView.navigationDelegate = self
        if let url = currentURL {
            self.webView.load(URLRequest(url: url))
        }

        // back/forward navigation buttons
        navigationItem.setLeftBarButtonItems([backBarButton, forwardBarButton], animated: true)
    }

    deinit {
        if let wView = webView, let url = wView.url {
            miniAppExternalUrlClose?(url)
        }
    }

    @objc
    func navigateBack() {
        webView.goBack()
    }

    @objc
    func navigateForward() {
        webView.goForward()
    }
}

extension MiniAppExternalWebViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.currentURL = self.webView.url
        self.backBarButton.isEnabled = webView.canGoBack
        self.forwardBarButton.isEnabled = webView.canGoForward
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        MiniAppLogger.e(String(describing: navigation), error)
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
