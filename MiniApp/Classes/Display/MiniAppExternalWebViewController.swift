import Foundation
import UIKit
import WebKit

class MiniAppExternalWebViewController: UIViewController {
    struct ReturnObject: Codable {
        var url: String?
    }

    var webView: WKWebView!
    var currentURL: URL?
    var miniAppExternalUrlLoader: MiniAppExternalUrlLoader?

    public class func presentModally(url: URL, externalLinkResponseHandler: MiniAppNavigationResponseHandler?) {
        let window: UIWindow?
        if #available(iOS 13, *) {
            window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        } else {
            window = UIApplication.shared.keyWindow
        }
        let webctrl = MiniAppExternalWebViewController()
        webctrl.currentURL = url
        let navigationController = MiniAppCloseNavigationController(rootViewController: webctrl)
        let closeButton = UIBarButtonItem(barButtonSystemItem: .done, target: navigationController, action: #selector(MiniAppCloseNavigationController.close))
        webctrl.navigationItem.rightBarButtonItem = closeButton
        webctrl.miniAppExternalUrlLoader = MiniAppExternalUrlLoader(webViewController: webctrl, responseHandler: externalLinkResponseHandler)
        //let safariVC = SFSafariViewController(url: url)
        window?.topController()?.present(navigationController, animated: true)

    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = .lightGray

        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        config.allowsInlineMediaPlayback = true
        config.allowsPictureInPictureMediaPlayback = true

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
        if navigationAction.navigationType == .linkActivated {
            if let url = navigationAction.request.url, !(navigationAction.targetFrame?.isMainFrame ?? false) {
                decisionHandler(.cancel)
                Self.presentModally(url: url, externalLinkResponseHandler: self.miniAppExternalUrlLoader?.currentResponseHandler)
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
