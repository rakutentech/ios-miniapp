import Foundation
import UIKit
import WebKit
import MiniApp

class ExternalWebViewController: UIViewController {
    struct ReturnObject: Codable {
        var url: String?
    }

    @IBOutlet var webView: WKWebView!
    var currentURL: URL?
    var miniAppExternalNavigationHandler: ((URL) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.navigationDelegate = self
        if let url = currentURL {
            self.webView.load(URLRequest(url: url))
        }
    }

    @IBAction func closeController(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }

}

extension ExternalWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.currentURL = self.webView.url
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let urlWebview = navigationAction.request.url, urlWebview.scheme?.starts(with: "mscheme") ?? false {
            self.miniAppExternalNavigationHandler?(urlWebview)
            decisionHandler(.cancel)
            self.dismiss(animated: true)
        } else {
            decisionHandler(.allow)
        }
    }
}
