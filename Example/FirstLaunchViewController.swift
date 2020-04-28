import UIKit
import MiniApp

class FirstLaunchViewController: UIViewController {

    @IBOutlet weak var imageViewArrow: UIImageView!
    @IBOutlet weak var labelHint: UILabel!
    @IBOutlet weak var labelMiniApp: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if checkSettingsOK() {
            self.performSegue(withIdentifier: "ShowList", sender: nil)
        } else {
            animateViews()
        }
    }

    func checkSettingsOK() -> Bool {
        return Config.userDefaults?.string(forKey: Config.Key.applicationIdentifier.rawValue) != nil && Config.userDefaults?.string(forKey: Config.Key.subscriptionKey.rawValue) != nil
    }

    func animateViews() {
        UIView.animate(withDuration: 1.5) {
            self.imageViewArrow.alpha = 1.0
            self.labelHint.alpha = 1.0
        }
        UIView.animate(withDuration: 0.5) {
            self.labelMiniApp.alpha = 0.0
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CustomConfiguration" {
            if let navigationController = segue.destination as? UINavigationController,
                let customSettingsController = navigationController.topViewController as? SettingsTableViewController {
                customSettingsController.configUpdateDelegate = self
            }
        } else if segue.identifier == "ShowList" {
            if let viewController = segue.destination as? ViewController {
                viewController.decodeResponse = sender as? [MiniAppInfo]
            }
        }
    }
}

extension FirstLaunchViewController: SettingsDelegate {
    func settings(controller: SettingsTableViewController, updated miniAppList: [MiniAppInfo]) {
        self.performSegue(withIdentifier: "ShowList", sender: miniAppList)
    }
}
