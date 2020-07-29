import WebKit

extension RealMiniAppView: WKUIDelegate {
    func webView(_ webView: WKWebView,
                 runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: self.miniAppTitle, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok_title".localizedString(), style: .default, handler: nil))
        UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
        completionHandler()
    }

    func webView(_ webView: WKWebView,
                 runJavaScriptConfirmPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: self.miniAppTitle, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok_title".localizedString(), style: .default, handler: { (_) in
            completionHandler(true)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel_title".localizedString(), style: .cancel, handler: { (_) in
            completionHandler(false)
        }))
        UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
    }

    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String,
                 defaultText: String?,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: self.miniAppTitle, message: prompt, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.text = defaultText
        }
        alertController.addAction(UIAlertAction(title: "Ok_title".localizedString(), style: .default, handler: { (_) in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel_title".localizedString(), style: .cancel, handler: { (_) in
            completionHandler(nil)
        }))
        UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
    }
}
