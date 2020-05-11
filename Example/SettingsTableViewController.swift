import UIKit
import MiniApp

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var textFieldAppID: UITextField!
    @IBOutlet weak var textFieldSubKey: UITextField!
    @IBOutlet weak var invalidHostAppIdLabel: UILabel!
    weak var configUpdateDelegate: SettingsDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.textFieldAppID.delegate = self
        self.textFieldSubKey.delegate = self
        self.invalidHostAppIdLabel.isHidden = true
        addTapGesture()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        resetFields()
        toggleSaveButton()
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
        if isValueEntered(text: self.textFieldAppID.text, key: .applicationIdentifier) && isValueEntered(text: self.textFieldSubKey.text, key: .subscriptionKey) {
            if self.textFieldAppID.text!.isValidUUID() {
                fetchAppList(withConfig: createConfig(hostAppId: self.textFieldAppID.text!, subscriptionKey: self.textFieldSubKey.text!))
            }
            displayInvalidValueErrorMessage(forKey: .applicationIdentifier)
        }
    }

    /// Fetch the mini app list for a given Host app ID and subscription key.
    /// Reload Mini App list only when successful response is received
    /// If error received with 200 as status code but there is no mini apps published in the platform, so we show a different error message
    func fetchAppList(withConfig: MiniAppSdkConfig) {
        showProgressIndicator(silently: false) {
            MiniApp.shared(with: withConfig).list { (result) in
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                }
                switch result {
                case .success(let responseData):
                    DispatchQueue.main.async {
                        self.configUpdateDelegate?.settings(controller: self, updated: responseData)
                        self.dismissProgressIndicator()
                        self.saveCustomConfiguration()
                    }
                case .failure(let error):
                    let errorInfo = error as NSError
                    if errorInfo.code != 200 {
                        print(error.localizedDescription)
                        self.displayAlert(title: NSLocalizedString("error_title", comment: ""), message: NSLocalizedString("error_list_message", comment: ""), dismissController: true)
                    } else {
                        DispatchQueue.main.async {
                            self.displayAlert(title: "Information", message: NSLocalizedString("error_no_miniapp_found", comment: ""), dismissController: true) { _ in
                                self.saveCustomConfiguration()
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
    }

    func saveCustomConfiguration() {
        self.save(field: self.textFieldAppID, for: .applicationIdentifier)
        self.save(field: self.textFieldSubKey, for: .subscriptionKey)
        self.displayAlert(title: NSLocalizedString("message_save_title", comment: ""),
            message: NSLocalizedString("message_save_text", comment: ""),
            autoDismiss: true) { _ in
                self.dismiss(animated: true, completion: nil)
            }
    }

    func createConfig(hostAppId: String, subscriptionKey: String) -> MiniAppSdkConfig {
        return MiniAppSdkConfig(baseUrl: Bundle.main.infoDictionary?[Config.Key.endpoint.rawValue] as? String,
                                rasAppId: hostAppId,
                                subscriptionKey: subscriptionKey,
                                hostAppVersion: Bundle.main.infoDictionary?[Config.Key.version.rawValue] as? String)
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

    func toggleSaveButton() {
        guard let hostAppId = Config.userDefaults?.string(forKey: Config.Key.applicationIdentifier.rawValue), hostAppId.isValidUUID(), !hostAppId.isEmpty else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            return
        }
    }

    func save(field: UITextField?, for key: Config.Key) {
        if let textField = field {
            Config.userDefaults?.set(textField.text, forKey: key.rawValue)
        } else {
            Config.userDefaults?.removeObject(forKey: key.rawValue)
        }
    }

    func isValueEntered(text: String?, key: Config.Key) -> Bool {
        guard let textFieldValue = text, !textFieldValue.isEmpty else {
            displayNoValueFoundErrorMessage(forKey: key)
            return false
        }
        return true
    }

    func displayInvalidValueErrorMessage(forKey: Config.Key) {
        switch forKey {
        case .applicationIdentifier:
        displayAlert(title: NSLocalizedString("error_title", comment: ""),
            message: NSLocalizedString("error_incorrect_appid_message", comment: ""),
            autoDismiss: true)
        case .subscriptionKey:
        displayAlert(title: NSLocalizedString("error_title", comment: ""),
            message: NSLocalizedString("error_incorrect_subscription_key_message", comment: ""),
            autoDismiss: false)
        default:
        break
        }
    }
    func displayNoValueFoundErrorMessage(forKey: Config.Key) {
        switch forKey {
        case .applicationIdentifier:
        displayAlert(title: NSLocalizedString("error_title", comment: ""),
            message: NSLocalizedString("error_empty_appid_key_message", comment: ""),
            autoDismiss: true)
        case .subscriptionKey:
        displayAlert(title: NSLocalizedString("error_title", comment: ""),
            message: NSLocalizedString("error_empty_subscription_key_message", comment: ""),
            autoDismiss: false)
        default:
        break
        }
    }

    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField.tag == 100 {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
        return true
    }

    public override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 100 {
            let textFieldValue = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            if !textFieldValue.isEmpty && textFieldValue.isValidUUID() {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                return true
            }
            self.invalidHostAppIdLabel.isHidden = true
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag != 100 {
            guard let hostAppId = self.textFieldAppID.text, !hostAppId.isEmpty && hostAppId.isValidUUID() else {
                self.invalidHostAppIdLabel.isHidden = false
                return
            }
            self.invalidHostAppIdLabel.isHidden = true
        }
    }
}

protocol SettingsDelegate: class {
    func settings(controller: SettingsTableViewController, updated miniAppList: [MiniAppInfo])
}
