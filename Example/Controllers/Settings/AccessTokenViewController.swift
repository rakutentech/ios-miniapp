import UIKit
import MiniApp

class AccessTokenViewController: UITableViewController {

    @IBOutlet weak var accessTokenTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var audienceTextField: UITextField!
    @IBOutlet weak var scopesTextField: UITextField!

    override func viewDidLoad() {
        retrieveAccessTokenInfo()
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
        self.audienceTextField.text = tokenInfo.audience
        self.scopesTextField.text = tokenInfo.scopes?.joined(separator: ", ")
    }

    func setDefaultTokenInfo() {
        self.accessTokenTextField.text = "ACCESS_TOKEN"
        self.datePicker.date = Date()
        self.audienceTextField.text = nil
        self.scopesTextField.text = nil
        saveTokenInfo(accessToken: "ACCESS_TOKEN", expiryDate: Date(), scopes: nil)
    }

    @IBAction func save() {
        if isValidTokenDetailsEntered() {
            saveTokenDetails()
        }
    }

    func isValidTokenDetailsEntered() -> Bool {
        if isValidInput(textField: self.accessTokenTextField),
           isValidInput(textField: self.scopesTextField, self.audienceTextField),
           isValidInput(textField: self.audienceTextField, self.scopesTextField) {
            return true
        }
        return false
    }

    func saveTokenDetails() {
        let saveStatus = saveTokenInfo(
            accessToken: self.accessTokenTextField.text ?? "ACCESS_TOKEN",
            expiryDate: self.datePicker.date,
            scopes: MASDKAccessTokenScopes(
                audience: self.audienceTextField.text,
                scopes: self.scopesTextField.text?.components(separatedBy: ",").compactMap({ (scope) -> String? in
                    scope.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                })
            )
        )
        if saveStatus {
            self.displayAlert(title: "Info", message: "Access Token info saved")
        } else {
            self.displayAlert(title: "Error", message: "Error while saving Token Info")
        }
    }

    func isValidInput(textField: UITextField, _ dependentField: UITextField? = nil, showError: Bool = true) -> Bool {
        if showError {
            if let dependentTextField = dependentField {
                let textFieldIsValid = isValidInput(textField: textField, showError: false)
                if textFieldIsValid {
                    return isValidInput(textField: dependentTextField)
                } else {
                    return true
                }
            }
        }
        guard let text = textField.text?.trimTrailingWhitespaces() else {
            if showError { displayErrorAlert(textfield: textField) }
            return false
        }
        if text.isEmpty {
            if showError { displayErrorAlert(textfield: textField) }
            return false
        }
        return true
    }

    func displayErrorAlert(textfield: UITextField) {
        if textfield.tag == 112 {
            DispatchQueue.main.async {
                self.displayAlert(title: "Error", message: "Please enter valid audience")
            }
        } else if textfield.tag == 113 {
            DispatchQueue.main.async {
                self.displayAlert(title: "Error", message: "Please enter valid scope")
            }
        } else {
            DispatchQueue.main.async {
                self.displayAlert(title: "Error", message: "Please enter valid Access Token")
            }
        }
    }
}
