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
        animateViews()
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
        }
    }
}

extension FirstLaunchViewController: SettingsDelegate {
    func didSettingsUpdated(controller: SettingsTableViewController, updated miniAppList: [MiniAppInfo]?) {
        dismiss(animated: true, completion: nil)
    }
}
