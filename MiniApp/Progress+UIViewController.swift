import UIKit

extension UIViewController {

    func showProgressIndicator(completion:(() -> Void)? = nil) {
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

    func dismissProgressIndicator(completion:(() -> Void)? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            self.dismiss(animated: true, completion: completion)
        })
    }

    func displayErrorAlert(title: String, message: String, dismissController: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.dismiss(animated: true, completion: {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: { (_: UIAlertAction!) in
                    if dismissController {
                        self.dismiss(animated: true, completion: nil)
                    }
                }))
                self.present(alert, animated: true, completion: nil)
            })
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

            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { (action) in
                handler?(action, alert.textFields?.first)
            }

            alert.addAction(UIAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: .cancel, handler: { (_) in
                self.dismiss(animated: true, completion: nil)
            }))
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
}
