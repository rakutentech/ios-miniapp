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
        guard let _ = Config.userDefaults?.string(forKey: Config.Key.applicationIdentifier.rawValue), let _ = Config.userDefaults?.string(forKey: Config.Key.subscriptionKey.rawValue) else {
            UIView.animate(withDuration: 1.5) {
                self.imageViewArrow.alpha = 1.0
                self.labelHint.alpha = 1.0
            }
            UIView.animate(withDuration: 0.5) {
                self.labelMiniApp.alpha = 0.0
            }
            return
        }
        self.performSegue(withIdentifier: "showList", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CustomConfiguration" {
            if let navigationController = segue.destination as? UINavigationController,
                let customSettingsController = navigationController.topViewController as? SettingsTableViewController {
                customSettingsController.configUpdateDelegate = self
            }
        }else if segue.identifier == "showList" {
            if let viewController = segue.destination as? ViewController {
                viewController.decodeResponse = sender as? [MiniAppInfo]
            }
        }
    }
}

extension FirstLaunchViewController: ConfigDelegate {
    func configDidUpdate(_ miniAppList: [MiniAppInfo]) {
        self.performSegue(withIdentifier: "showList", sender: miniAppList)
    }
}
