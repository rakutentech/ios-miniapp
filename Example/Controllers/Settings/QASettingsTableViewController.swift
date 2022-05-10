import UIKit
import MiniApp

enum AccessTokenCustomErrorType: String {
    case AUTHORIZATION,
         OTHER
}

class QASettingsTableViewController: RATTableViewController {
    public static let preferenceAccessTokenBehavior = "QA_CUSTOM_ACCESS_TOKEN_ERROR_TYPE"
    public static let preferenceAccessTokenMessage = "QA_CUSTOM_ACCESS_TOKEN_ERROR_MESSAGE"
    @IBOutlet weak var accessTokenErrorControl: UISegmentedControl!
    @IBOutlet weak var accessTokenErrorCustomMessage: UITextField!
    @IBOutlet weak var wipeSecureStorageButton: UIButton!
    @IBOutlet weak var miniAppIdTextField: UITextField!
    @IBOutlet weak var wipeSecureStorageForMiniAppButton: UIButton!
    @IBOutlet weak var miniAppMaxSecureStorageLimitTextField: UITextField!
    @IBOutlet weak var miniAppMaxSecureStorageLimitButton: UIButton!
    
    let storageLimitFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.maximumFractionDigits = 0
        nf.decimalSeparator = "."
        return nf
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch Self.accessTokenErrorType() {
        case .AUTHORIZATION:
            accessTokenErrorControl.selectedSegmentIndex = 1
        case .OTHER:
            accessTokenErrorControl.selectedSegmentIndex = 2
        default:
            accessTokenErrorControl.selectedSegmentIndex = 0
        }
        accessTokenErrorCustomMessage.text = Self.accessTokenErrorMessage()
        self.pageName = MASDKLocale.localize("demo.app.rat.page.name.qa")
        wipeSecureStorageForMiniAppButton.setTitle("", for: .normal)
        miniAppMaxSecureStorageLimitButton.setTitle("", for: .normal)
        let maxSecureStorageLimit = UserDefaults.standard.integer(forKey: Config.LocalKey.maxSecureStorageFileLimit.rawValue)
        if maxSecureStorageLimit > 0 {
            miniAppMaxSecureStorageLimitTextField.text = storageLimitFormatter.string(from: NSNumber(value: maxSecureStorageLimit))
        }
    }

    public class func accessTokenErrorType() -> AccessTokenCustomErrorType? {
        guard let value = UserDefaults.standard.string(forKey: preferenceAccessTokenBehavior) else {
            return nil
        }
        return AccessTokenCustomErrorType(rawValue: value)
    }

    public class func accessTokenErrorMessage() -> String? {
        UserDefaults.standard.string(forKey: preferenceAccessTokenMessage)
    }

    @IBAction func accesstokenBehaviorChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 1:
            UserDefaults.standard.setValue(AccessTokenCustomErrorType.AUTHORIZATION.rawValue, forKey: Self.preferenceAccessTokenBehavior)
        case 2:
            UserDefaults.standard.setValue(AccessTokenCustomErrorType.OTHER.rawValue, forKey: Self.preferenceAccessTokenBehavior)
        default:
            UserDefaults.standard.removeObject(forKey: Self.preferenceAccessTokenBehavior)
        }
        setCustomTokenErrorMessage()
    }

    @IBAction func onWipeSecureStoragesPressed(_ sender: Any) {
        MiniApp.shared().clearAllSecureStorage()
        self.displayAlert(title: "Success", message: "All stores were wiped successfully!")
    }

    @IBAction func onWipeSecureStorageForMiniAppId(_ sender: Any) {
        guard let textFieldValue = self.miniAppIdTextField.text, !textFieldValue.isEmpty else {
            self.displayAlert(title: MASDKLocale.localize("input_valid_miniapp_title"), message: MASDKLocale.localize("miniapp.sdk.ios.error.message.invalid_miniapp_id"))
            return
        }
        MiniApp.shared().clearSecureStorage(for: textFieldValue)
        self.displayAlert(title: "Success", message: "Mini App Storage cleared!")
    }

    @IBAction func onSaveMaxStorageLimit(_ sender: Any) {
        guard
            let text = miniAppMaxSecureStorageLimitTextField.text,
            let textNumber = storageLimitFormatter.number(from: text),
            let textIntString = storageLimitFormatter.string(from: textNumber)
        else {
            self.displayAlert(title: "Failure", message: "Something went wrong")
            return
        }
        let textInt = Int(truncating: textNumber)
        self.miniAppMaxSecureStorageLimitTextField.text = textIntString
        UserDefaults.standard.set(textInt, forKey: Config.LocalKey.maxSecureStorageFileLimit.rawValue)
        UserDefaults.standard.synchronize()
        miniAppMaxSecureStorageLimitTextField.resignFirstResponder()
        self.displayAlert(title: "Success", message: "Saved Max Storage Size Limit to \(textIntString) bytes.")
    }
    
    func setCustomTokenErrorMessage() {
        if let text = accessTokenErrorCustomMessage.text, !text.isEmpty {
            print(text)
            UserDefaults.standard.setValue(text, forKey: Self.preferenceAccessTokenMessage)
        } else {
            print("no text")
            UserDefaults.standard.removeObject(forKey: Self.preferenceAccessTokenMessage)
        }
    }
}

extension QASettingsTableViewController {
    override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        setCustomTokenErrorMessage()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        setCustomTokenErrorMessage()
    }
}
