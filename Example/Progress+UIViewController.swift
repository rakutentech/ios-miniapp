import UIKit

extension UIViewController {

    func showProgressIndicator(silently: Bool = false, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            if silently {
                if let launchCompletion = completion {
                    launchCompletion()
                }
            } else {
                let alert = UIAlertController(title: nil, message: NSLocalizedString("wait_message", comment: ""), preferredStyle: .alert)
                let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
                loadingIndicator.hidesWhenStopped = true
                loadingIndicator.style = UIActivityIndicatorView.Style.gray
                loadingIndicator.startAnimating()
                alert.view.addSubview(loadingIndicator)
                self.present(alert, animated: true, completion: completion)
            }
        }
    }

    func dismissProgressIndicator(completion: (() -> Void)? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
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
                handler?(action, alert.textFields?.first)
            }

            alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: { (_) in
                    self.dismiss(animated: true, completion: nil)
                }))
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
}
