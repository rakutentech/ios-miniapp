import UIKit
import MiniApp

class SignatureSettingsTableViewController: RATTableViewController {

    @IBOutlet weak var signatureCheckSettingControl: UISegmentedControl!

    override func viewDidLoad() {
        setLayout(signatureCheckSetting: Config.userDefaults?.value(forKey: Config.Key.requireMiniAppSignatureVerification.rawValue) as?
                                         Bool)
        self.pageName = MASDKLocale.localize("demo.app.rat.page.name.deeplink")
    }

    func setLayout(signatureCheckSetting: Bool?) {
        if let forceCheck = signatureCheckSetting {
            signatureCheckSettingControl.selectedSegmentIndex = forceCheck ? 1 : 0
        } else {
            signatureCheckSettingControl.selectedSegmentIndex = 2
        }
    }

    @IBAction func signatureSettingChanged() {
        let selectedSegmentIndex = signatureCheckSettingControl.selectedSegmentIndex
        guard selectedSegmentIndex == 2 else {
            Config.userDefaults?.set(selectedSegmentIndex == 1, forKey: Config.Key.requireMiniAppSignatureVerification.rawValue)
            return
        }
        setDefaultSignatureCheckSetting()
    }

    func setDefaultSignatureCheckSetting() {
        Config.userDefaults?.removeObject(forKey: Config.Key.requireMiniAppSignatureVerification.rawValue)
    }
}
