@testable import MiniApp
import WebKit

class MockRealMiniAppView: RealMiniAppView {
    enum DialogButton {
        case okButton, cancelButton, okWithText
    }

    var currentHandler: Any?
    var dialogTitle, dialogMessage, dialogTextFieldText, okText, cancelText: String?

    func tapButton(_ button: DialogButton?) {
        if let title = button == .cancelButton ? cancelText : okText {
            tapAlertButton(title: title, actions: currentDialogController?.actions)
        } else {
            if button == .okWithText, let handler = currentHandler as? ((String?) -> Void) {
                handler("dummText")
            } else if let handler = currentHandler as? ((Bool?) -> Void) {
                handler(button == .cancelButton ? false : true)
            } else {
                (currentHandler as? (() -> Void))?()
            }
        }
    }

    override func webView(_ webView: WKWebView,
                          runJavaScriptAlertPanelWithMessage message: String,
                          initiatedByFrame frame: WKFrameInfo,
                          completionHandler: @escaping () -> Void) {
        super.webView(webView,
                      runJavaScriptAlertPanelWithMessage: message,
                      initiatedByFrame: frame,
                      completionHandler: completionHandler)
        populateVariables(dialogTitle: self.miniAppTitle,
                          dialogMessage: message,
                          okText: "Ok_title".localizedString())
        self.currentHandler = completionHandler
    }

    override func webView(_ webView: WKWebView,
                          runJavaScriptConfirmPanelWithMessage message: String,
                          initiatedByFrame frame: WKFrameInfo,
                          completionHandler: @escaping (Bool) -> Void) {
        super.webView(webView,
                      runJavaScriptConfirmPanelWithMessage: message,
                      initiatedByFrame: frame,
                      completionHandler: completionHandler)
        populateVariables(dialogTitle: self.miniAppTitle,
                          dialogMessage: message,
                          okText: "Ok_title".localizedString(),
                          cancelText: "Cancel_title".localizedString())
        self.currentHandler = completionHandler
    }

    override func webView(_ webView: WKWebView,
                          runJavaScriptTextInputPanelWithPrompt prompt: String,
                          defaultText: String?,
                          initiatedByFrame frame: WKFrameInfo,
                          completionHandler: @escaping (String?) -> Void) {
        super.webView(webView, runJavaScriptTextInputPanelWithPrompt: prompt, defaultText: defaultText, initiatedByFrame: frame, completionHandler: completionHandler)
        populateVariables(dialogTitle: self.miniAppTitle,
                          dialogMessage: prompt,
                          okText: "Ok_title".localizedString(),
                          cancelText: "Cancel_title".localizedString(),
                          dialogTextFieldText: defaultText)
        self.currentHandler = completionHandler
    }

    func populateVariables(dialogTitle: String? = nil,
                           dialogMessage: String? = nil,
                           okText: String? = nil,
                           cancelText: String? = nil,
                           dialogTextFieldText: String? = nil) {
        self.dialogTitle = dialogTitle
        self.dialogMessage = dialogMessage
        self.dialogTextFieldText = dialogTextFieldText
        self.okText = okText
        self.cancelText = cancelText
    }

    func tapAlertButton(title: String, actions: [UIAlertAction]?) {
        typealias AlertHandler = @convention(block) (UIAlertAction) -> Void

        guard let action = actions?.first(where: { $0.title == title }), let block = action.value(forKey: "handler") else { return }
        let handler = unsafeBitCast(block as AnyObject, to: AlertHandler.self)
        handler(action)
    }
}
