import WebKit

extension RealMiniAppView: WKUIDelegate {
    func webView(_ webView: WKWebView,
                 runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: self.miniAppTitle, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok_title".localizedString(), style: .default) { (_) in
            completionHandler()
        })
        currentDialogController = alertController
        presentAlert(alertController: alertController)
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
        currentDialogController = alertController
        presentAlert(alertController: alertController)
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
            if let text = alertController.textFields?.first?.text, text.count > 0 {
                completionHandler(text)
            } else {
                completionHandler("")
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel_title".localizedString(), style: .cancel, handler: { (_) in
            completionHandler(nil)
        }))
        currentDialogController = alertController
        presentAlert(alertController: alertController)
    }
}
