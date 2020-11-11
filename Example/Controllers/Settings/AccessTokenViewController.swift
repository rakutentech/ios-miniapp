import UIKit
import MiniApp

class AccessTokenViewController: UIViewController {

    @IBOutlet weak var accessTokenTextField: UITextField!
    @IBOutlet weak var expiryDateTextField: UITextField!
    var expiryDate = Date()

    override func viewDidLoad() {
        self.expiryDateTextField.delegate = self
        self.expiryDateTextField.setDatePickerInputView(target: self, selector: #selector(pickerViewDoneButtonTapped))
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
        self.expiryDateTextField.text = formatDateToDisplay(date: tokenInfo.expiryDate)
    }

    func setDefaultTokenInfo() {
        self.accessTokenTextField.text = "ACCESS_TOKEN"
        self.expiryDateTextField.text = formatDateToDisplay(date: Date())
        _ = saveTokenInfo(accessToken: "ACCESS_TOKEN", expiryDate: Date())
    }

    @IBAction func save() {
        if isValidTokenDetailsEntered() {
            saveTokenDetails()
        }
    }

    func isValidTokenDetailsEntered() -> Bool {
        if isValidInput(textField: self.accessTokenTextField) && isValidInput(textField: self.expiryDateTextField) {
            return true
        }
        return false
    }

    func saveTokenDetails() {
        let saveStatus = saveTokenInfo(accessToken: self.accessTokenTextField.text ?? "ACCESS_TOKEN", expiryDate: expiryDate)
        if saveStatus {
            self.displayAlert(title: "Info", message: "Access Token info saved")
        } else {
            self.displayAlert(title: "Error", message: "Error while saving Token Info")
        }
    }

    func isValidInput(textField: UITextField) -> Bool {
        guard let text = textField.text?.trimTrailingWhitespaces() else {
            displayErrorAlert(textfield: textField)
            return false
        }
        if text.isEmpty {
            displayErrorAlert(textfield: textField)
            return false
        }
        return true
    }

    func displayErrorAlert(textfield: UITextField) {
        if textfield.tag == 111 {
            DispatchQueue.main.async {
                self.displayAlert(title: "Error", message: "Please enter valid Expiry date")
            }
        } else {
            DispatchQueue.main.async {
                self.displayAlert(title: "Error", message: "Please enter valid Access Token")
            }
        }
    }

    @objc func pickerViewDoneButtonTapped() {
        if let datePicker = self.expiryDateTextField.inputView as? UIDatePicker {
            self.expiryDateTextField.text = formatDateToDisplay(date: datePicker.date)
            expiryDate = datePicker.date
        }
        self.expiryDateTextField.resignFirstResponder()
    }

    func formatDateToDisplay(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }

    override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 111 {
            return false
        } else {
            return true
        }
    }
}

extension UITextField {

    func setDatePickerInputView(target: Any, selector: Selector) {
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 216))
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date()
        self.inputView = datePicker
        self.inputAccessoryView = getPickerViewToolbar(selector: selector)
    }

    func getPickerViewToolbar(selector: Selector) -> UIToolbar {
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 44.0))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: #selector(dismissDatePicker))
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: target, action: selector)
        toolBar.setItems([cancelButton, flexibleSpace, doneButton], animated: false)
        return toolBar
    }

    @objc func dismissDatePicker() {
        self.resignFirstResponder()
    }
}
