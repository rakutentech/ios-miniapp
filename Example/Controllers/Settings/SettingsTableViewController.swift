import UIKit
import MiniApp

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var endPointSegmentedControl: UISegmentedControl!
    @IBOutlet weak var textFieldAppID: UITextField!
    @IBOutlet weak var textFieldSubKey: UITextField!
    @IBOutlet weak var invalidHostAppIdLabel: UILabel!
    @IBOutlet weak var invalidSubscriptionKeyLabel: UILabel!
    weak var configUpdateDelegate: SettingsDelegate?

    let predefinedKeys: [String] = ["RAS_PROJECT_IDENTIFIER", "RAS_SUBSCRIPTION_KEY", ""]
    let localizedErrorTitle = MASDKLocale.localize("miniapp.sdk.ios.error.title")

    enum SectionHeader: Int {
        case RAS = 1
        case profile = 2
        case previewMode = 0
    }
    enum TestMode: Int, CaseIterable {
        case HOSTED,
             PREVIEW

        func stringValue() -> String {
            switch self {
            case .HOSTED:
                return MASDKLocale.localize("miniapp.sdk.ios.mode.publishing")
            case .PREVIEW:
                return MASDKLocale.localize("miniapp.sdk.ios.mode.previewing")
            }
        }

        func isPreviewMode() -> Bool {
            switch self {
            case .HOSTED:
                return false
            case .PREVIEW:
                return true
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.textFieldAppID.delegate = self
        self.textFieldSubKey.delegate = self
        addTapGesture()
        addBuildVersionLabel()
        self.tableView.separatorStyle = .singleLine
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        resetFields()
        toggleSaveButton()
    }

    func resetFields() {
        self.invalidHostAppIdLabel.isHidden = true
        self.invalidSubscriptionKeyLabel.isHidden = true
        configure(field: self.textFieldAppID, for: .projectId)
        configure(field: self.textFieldSubKey, for: .subscriptionKey)
        configureMode()
    }

    @IBAction func actionResetConfig(_ sender: Any) {
        resetFields()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func actionSaveConfig() {
        if isValueEntered(text: self.textFieldAppID.text, key: .projectId) && isValueEntered(text: self.textFieldSubKey.text, key: .subscriptionKey) {
            if self.textFieldAppID.text!.isValidUUID() {
                let selectedMode = TestMode(rawValue: self.endPointSegmentedControl.selectedSegmentIndex)
                let isPreview = selectedMode?.isPreviewMode() ?? true

                fetchAppList(withConfig:
                                createConfig(
                                    projectId: self.textFieldAppID.text!,
                                    subscriptionKey: self.textFieldSubKey.text!,
                                    loadPreviewVersions: isPreview
                                )
                )
            }
            displayInvalidValueErrorMessage(forKey: .projectId)
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
                        self.dismissProgressIndicator()
                        self.saveCustomConfiguration(responseData: responseData)
                    }
                case .failure(let error):
                    let errorInfo = error as NSError
                    if errorInfo.code != 200 {
                        print(error.localizedDescription)
                        self.displayAlert(
                            title: MASDKLocale.localize("miniapp.sdk.ios.error.title"),
                            message: MASDKLocale.localize("miniapp.sdk.ios.error.message.list"),
                            dismissController: true)
                    } else {
                        DispatchQueue.main.async {
                            self.displayAlert(
                                title: MASDKLocale.localize("Information"),
                                message: MASDKLocale.localize("miniapp.sdk.ios.error.message.no_miniapp_found"), dismissController: true) { _ in
                                self.saveCustomConfiguration(responseData: nil)
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
    }

    func saveCustomConfiguration(responseData: [MiniAppInfo]?) {
        self.save(field: self.textFieldAppID, for: .projectId)
        self.save(field: self.textFieldSubKey, for: .subscriptionKey)
        self.saveMode()

        self.displayAlert(title: MASDKLocale.localize("miniapp.sdk.ios.param.save_title"),
                          message: MASDKLocale.localize("miniapp.sdk.ios.param.save_text"),
                          autoDismiss: true) { _ in
            self.dismiss(animated: true, completion: nil)
            guard let miniAppList = responseData else {
                self.configUpdateDelegate?.didSettingsUpdated(controller: self, updated: nil)
                return
            }
            self.configUpdateDelegate?.didSettingsUpdated(controller: self, updated: miniAppList)
        }
    }

    func createConfig(projectId: String, subscriptionKey: String, loadPreviewVersions: Bool) -> MiniAppSdkConfig {
        return MiniAppSdkConfig(
            rasProjectId: projectId,
            subscriptionKey: subscriptionKey,
            hostAppVersion: Bundle.main.infoDictionary?[Config.Key.version.rawValue] as? String,
            isPreviewMode: loadPreviewVersions)
    }

    /// Adding Tap gesture to dismiss the Keyboard
    func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    func configure(field: UITextField?, for key: Config.Key) {
        field?.placeholder = Bundle.main.infoDictionary?[key.rawValue] as? String
        field?.text = getTextFieldValue(key: key, placeholderText: field?.placeholder)
    }

    func configureMode() {
        self.endPointSegmentedControl.removeAllSegments()
        TestMode.allCases.forEach { configure(mode: $0) }
        let defaultMode = (Bundle.main.infoDictionary?[Config.Key.isPreviewMode.rawValue] as? Bool ?? true).intValue
        if let index = Config.userDefaults?.value(forKey: Config.Key.isPreviewMode.rawValue) {
            self.endPointSegmentedControl.selectedSegmentIndex = (index as? Bool)?.intValue ?? defaultMode
        } else {
            self.endPointSegmentedControl.selectedSegmentIndex = defaultMode
        }
    }

    func configure(mode: TestMode) {
        self.endPointSegmentedControl.insertSegment(withTitle: mode.stringValue(), at: mode.rawValue, animated: false)
    }

    func getTextFieldValue(key: Config.Key, placeholderText: String?) -> String? {
        guard let value = Config.userDefaults?.string(forKey: key.rawValue) else {
            return placeholderText
        }
        return value
    }

    func toggleSaveButton() {
        if !self.textFieldAppID.text!.isValidUUID() || self.textFieldSubKey.text!.isEmpty {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            return
        }
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }

    func save(field: UITextField?, for key: Config.Key) {
        if let textField = field {
            Config.userDefaults?.set(textField.text, forKey: key.rawValue)
        } else {
            Config.userDefaults?.removeObject(forKey: key.rawValue)
        }
    }

    func saveMode() {
        let selectedMode = self.endPointSegmentedControl.selectedSegmentIndex
        Config.userDefaults?.set(selectedMode.boolValue, forKey: Config.Key.isPreviewMode.rawValue)
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
        case .projectId:
            displayAlert(title: localizedErrorTitle,
                         message: MASDKLocale.localize("miniapp.sdk.ios.error.message.incorrect_appid"),
                         autoDismiss: true)
        case .subscriptionKey:
            displayAlert(title: localizedErrorTitle,
                         message: MASDKLocale.localize("miniapp.sdk.ios.error.message.incorrect_subscription_key"),
                         autoDismiss: false)
        default:
            break
        }
    }
    func displayNoValueFoundErrorMessage(forKey: Config.Key) {
        switch forKey {
        case .projectId:
            displayAlert(title: localizedErrorTitle,
                         message: MASDKLocale.localize("miniapp.sdk.ios.error.message.empty_appid_key"),
                         autoDismiss: true)
        case .subscriptionKey:
            displayAlert(title: localizedErrorTitle,
                         message: MASDKLocale.localize("miniapp.sdk.ios.error.message.empty_subscription_key"),
                         autoDismiss: false)
        default:
            break
        }
    }

    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField.tag == 100 {
            self.invalidHostAppIdLabel.isHidden = true
        } else {
            self.invalidSubscriptionKeyLabel.isHidden = true
        }
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        return true
    }

    public override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldValue = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        validateTextFields(textField: textField, and: textFieldValue)
        if textFieldValue.isEmpty {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            return true
        }
        if textField.tag == 100 {
            self.navigationItem.rightBarButtonItem?.isEnabled = textFieldValue.isValidUUID()
            return true
        }
        if self.textFieldAppID.text!.isValidUUID() {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            return true
        }
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        validateTextFields(textField: textField, and: textField.text ?? "")
    }

    func validateTextFields(textField: UITextField, and value: String) {
        if textField.tag == 100 {
            self.invalidHostAppIdLabel.isHidden = value.isValidUUID()
            return
        }
        self.invalidSubscriptionKeyLabel.isHidden = !value.isEmpty
    }

    func addBuildVersionLabel() {
        self.navigationItem.prompt = getBuildVersionText()
    }

    func getBuildVersionText() -> String {
        var versionText = ""
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionText.append("Build Version: \(version) - ")

        }
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            versionText.append("(\(build))")
        }
        return versionText
    }
}

protocol SettingsDelegate: AnyObject {
    func didSettingsUpdated(controller: SettingsTableViewController, updated miniAppList: [MiniAppInfo]?)
}

extension SettingsTableViewController {
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case SectionHeader.previewMode.rawValue:
            return "Preview Mode"
        case SectionHeader.profile.rawValue:
            return ""
        case SectionHeader.RAS.rawValue:
            return "RAS"
        default:
            return nil
        }
    }
}
