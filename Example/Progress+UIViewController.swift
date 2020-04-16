import UIKit

extension UIViewController {

    func showProgressIndicator(completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: NSLocalizedString("wait_message", comment: ""), preferredStyle: .alert)
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = UIActivityIndicatorView.Style.gray
            loadingIndicator.startAnimating()
            alert.view.addSubview(loadingIndicator)
            self.present(alert, animated: true, completion: completion)
        }
    }

    func dismissProgressIndicator(completion: (() -> Void)? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                self.dismiss(animated: true, completion: completion)
            })
    }

    func displayAlert(title: String, message: String, dismissController: Bool, autoDismiss: Bool? = true, okHandler: ((UIAlertAction) -> Void)? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if dismissController {
                self.dismiss(animated: true, completion: {
                    self.displayAlert(title: title,
                        message: message,
                        autoDismiss: autoDismiss,
                        okHandler: okHandler)
                })
            }
        }
    }

    func displayAlert(title: String, message: String, autoDismiss: Bool? = true, okHandler: ((UIAlertAction) -> Void)? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: { (action: UIAlertAction!) in
                    if let actionHandler = okHandler {
                        actionHandler(action)
                    }
                    if autoDismiss ?? true {
                        alert.dismiss(animated: true, completion: nil)
                    }
                }))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func displayTextFieldAlert(title: String? = nil, message: String? = nil, keyboardType: UIKeyboardType? = .asciiCapable, handler: ((UIAlertAction, UITextField?) -> Void)? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let alert = UIAlertController(title: title,
                message: message,
                preferredStyle: .alert)
            alert.addTextField { (textField) in
                if let type = keyboardType {
                    textField.keyboardType = type
                }
            }

            let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                if UUID(uuidString: alert.textFields![0].text!) != nil {
                    handler?(action, alert.textFields?.first)
                } else {
                    self.displayErrorInAlertController(alertController: alert, message: NSLocalizedString("error_invalid_miniapp_id", comment: ""))
                    self.present(alert, animated: true, completion: nil)
                    // The below code is to remove the error message after three seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.displayErrorInAlertController(alertController: alert, message: "")
                    }
                }
            }

            alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: { (_) in
                    self.dismiss(animated: true, completion: nil)
                }))
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }

    /// Method to add a Attributed string as Error message for a given UIAlertController
    /// - Parameters:
    ///   - alertController: UIAlertController object in which you want to display error message
    ///   - message: Error message description
    func displayErrorInAlertController(alertController: UIAlertController, message: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        let attributedString = NSAttributedString(string: message, attributes: [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
            NSAttributedString.Key.foregroundColor: UIColor.red
        ])
        alertController.setValue(attributedString, forKey: "attributedMessage")
    }
}
