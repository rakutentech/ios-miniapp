import UIKit
import MiniApp

class AccessTokenViewController: RATTableViewController {

    @IBOutlet weak var accessTokenTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!

    override func viewDidLoad() {
        retrieveAccessTokenInfo()
        self.pageName = MASDKLocale.localize("demo.app.rat.page.name.access_token")
    }

    func retrieveAccessTokenInfo() {
        guard let tokenInfo = getTokenInfo() else {
            setDefaultTokenInfo()
            return
        }
        setLayout(tokenInfo: tokenInfo)
    }

    func setLayout(tokenInfo: AccessTokenInfo) {
        self.accessTokenTextField.text = tokenInfo.tokenString
        self.datePicker.date = tokenInfo.expiryDate
    }

    func setDefaultTokenInfo() {
        self.accessTokenTextField.text = "ACCESS_TOKEN"
        self.datePicker.date = Date()
        saveTokenInfo(accessToken: "ACCESS_TOKEN", expiryDate: Date(), scopes: nil)
    }

    @IBAction func save() {
        if isValidInput(textField: self.accessTokenTextField) {
            saveTokenDetails()
        }
    }

    func saveTokenDetails() {
        let saveStatus = saveTokenInfo(
            accessToken: self.accessTokenTextField.text ?? "ACCESS_TOKEN",
            expiryDate: self.datePicker.date,
            scopes: nil
        )
        if saveStatus {
            self.displayAlert(title: "Info", message: "Access Token info saved")
        } else {
            self.displayAlert(title: "Error", message: "Error while saving Token Info")
        }
    }

    func isValidInput(textField: UITextField, showError: Bool = true) -> Bool {
        if let text = textField.text?.trimTrailingWhitespaces(), !text.isEmpty {
            return true
        }
        if showError {
            DispatchQueue.main.async {
                self.displayAlert(title: "Error", message: "Please enter valid Access Token")
            }
        }
        return false
    }
}
