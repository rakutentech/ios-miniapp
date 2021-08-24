import UIKit
import MiniApp

extension UIViewController: UITextFieldDelegate {

    func showProgressIndicator(silently: Bool = false, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            if silently {
                if let launchCompletion = completion {
                    launchCompletion()
                }
            } else {
                let alert = UIAlertController(title: nil, message: MASDKLocale.localize("miniapp.sdk.ios.message.wait"), preferredStyle: .alert)
                let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
                loadingIndicator.hidesWhenStopped = true
                loadingIndicator.style = UIActivityIndicatorView.Style.medium
                loadingIndicator.startAnimating()
                alert.view.addSubview(loadingIndicator)
                self.present(alert, animated: true, completion: completion)
            }
        }
    }

    func dismissProgressIndicator(completion: (() -> Void)? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            if self.presentedViewController as? UIAlertController != nil {
                self.dismiss(animated: true, completion: completion)
            }
            completion?()
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

            alert.addAction(UIAlertAction(title: MASDKLocale.localize(.ok), style: .default, handler: { (action: UIAlertAction!) in
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
                textField.delegate = self
                if let type = keyboardType {
                    textField.keyboardType = type
                }
            }

            let okAction = UIAlertAction(title: MASDKLocale.localize(.ok), style: .default) { (action) in
                if alert.textFields![0].text!.isValidUUID() {
                    handler?(action, alert.textFields?.first)
                } else {
                    handler?(action, nil)
                }
            }
            okAction.isEnabled = false
            alert.addAction(UIAlertAction(title: MASDKLocale.localize(.cancel), style: .cancel, handler: { (_) in
                    self.dismiss(animated: true, completion: nil)
                }))
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let alertController = self.presentedViewController as? UIAlertController else {
            return true
        }
        let okButtonAction: UIAlertAction = alertController.actions[1]
        let textFieldValue = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if !textFieldValue.isEmpty {
            okButtonAction.isEnabled = true
        } else {
            okButtonAction.isEnabled = false
        }
        return true
    }
}
