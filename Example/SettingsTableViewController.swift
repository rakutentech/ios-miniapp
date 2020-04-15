import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var textFieldAppID: UITextField!
    @IBOutlet weak var textFieldSubKey: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGesture()
    }

    override func viewDidAppear(_ animated: Bool) {
        resetFields()
    }

    func resetFields() {
        configure(field: self.textFieldAppID, for: .applicationIdentifier)
        configure(field: self.textFieldSubKey, for: .subscriptionKey)
    }

    @IBAction func actionResetConfig(_ sender: Any) {
        resetFields()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func actionSaveConfig() {
        save(field: self.textFieldAppID, for: .applicationIdentifier)
        save(field: self.textFieldSubKey, for: .subscriptionKey)
        displayAlert(title: NSLocalizedString("message_save_title", comment: ""),
            message: NSLocalizedString("message_save_text", comment: ""),
            autoDismiss: true) { _ in
            self.dismiss(animated: true, completion: nil)
        }
    }

    /// Adding Tap gesture to dismiss the Keyboard
    func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    func configure(field: UITextField?, for key: Config.Key) {
        field?.placeholder = Bundle.main.infoDictionary?[key.rawValue] as? String
        field?.text = Config.userDefaults?.string(forKey: key.rawValue)
    }

    func save(field: UITextField?, for key: Config.Key) {
        if let textField = field {
            Config.userDefaults?.set(textField.text, forKey: key.rawValue)
        } else {
            Config.userDefaults?.removeObject(forKey: key.rawValue)
        }
    }

}
