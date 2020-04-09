import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var textFieldAppID: UITextField!
    @IBOutlet weak var textFieldSubKey: UITextField!
    @IBOutlet weak var textFieldURL: UITextField!
    @IBOutlet weak var textFieldVersion: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGesture()
    }

    override func viewDidAppear(_ animated: Bool) {
        configure(field: self.textFieldAppID, for: .applicationIdentifier)
        configure(field: self.textFieldSubKey, for: .subscriptionKey)
        configure(field: self.textFieldVersion, for: .version)
        configure(field: self.textFieldURL, for: .endpoint)
    }

    @IBAction func actionSaveConfig() {
        save(field: self.textFieldAppID, for: .applicationIdentifier)
        save(field: self.textFieldSubKey, for: .subscriptionKey)
        save(field: self.textFieldVersion, for: .version)
        save(field: self.textFieldURL, for: .endpoint)
        displayAlert(title: NSLocalizedString("message_save_title", comment: ""), message: NSLocalizedString("message_save_text", comment: ""), dismissController: false)
    }
    
    /// Adding Tap gesture to dismiss the Keyboard
    func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    func configure(field: UITextField, for key: Config.Key) {
        field.placeholder = Bundle.main.infoDictionary?[key.rawValue] as? String
        field.text = Config.userDefaults?.string(forKey: key.rawValue)
    }

    func save(field: UITextField, for key: Config.Key) {
        Config.userDefaults?.set(field.text, forKey: key.rawValue)
    }

}
