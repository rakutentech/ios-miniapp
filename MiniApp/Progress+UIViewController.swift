import UIKit

extension UIViewController {

    func showProgressIndicator() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = UIActivityIndicatorView.Style.gray
            loadingIndicator.startAnimating()
            alert.view.addSubview(loadingIndicator)
            self.present(alert, animated: true, completion: nil)
        }
    }

    func dismissProgressIndicator() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.dismiss(animated: true, completion: nil)
        })
    }

    func displayErrorAlert(title: String, message: String, dimissController: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.dismiss(animated: true, completion: {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_: UIAlertAction!) in
                    if dimissController {
                        self.dismiss(animated: true, completion: nil)
                    }
                }))
                self.present(alert, animated: true, completion: nil)
            })
        }
    }
}
