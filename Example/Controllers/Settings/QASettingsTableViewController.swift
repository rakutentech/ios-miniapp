import UIKit

enum AccessTokenCustomErrorType: String {
    case AUTHORIZATION,
         OTHER
}

class QASettingsTableViewController: UITableViewController {
    public static let preferenceAccessTokenBehavior = "QA_CUSTOM_ACCESS_TOKEN_ERROR_TYPE"
    public static let preferenceAccessTokenMessage = "QA_CUSTOM_ACCESS_TOKEN_ERROR_MESSAGE"
    @IBOutlet weak var accessTokenErrorControl: UISegmentedControl!
    @IBOutlet weak var accessTokenErrorCustomMessage: UITextField!

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
