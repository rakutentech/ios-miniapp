import UIKit
import MiniApp

class DisplayController: UIViewController {

    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var forwardButton: UIBarButtonItem!
    weak var navBarDelegate: MiniAppNavigationBarDelegate?

    override func viewDidAppear(_ animated: Bool) {
        guard let controller = self.navigationController as? DisplayNavigationController, let info = controller.miniAppInfo, let miniAppDisplay = controller.miniAppDisplay else {
            return
        }

        self.title = info.displayName

        let view = miniAppDisplay.getMiniAppView()
        view.frame = self.view.bounds
        self.navBarDelegate = miniAppDisplay as? MiniAppNavigationBarDelegate
        self.view.addSubview(view)
    }

    @IBAction func done(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func navigate(_ sender: UIBarButtonItem) {
        switch sender {
        case backButton:
            if !(self.navBarDelegate?.miniAppNavigationBar(didTriggerAction: .back) ?? false) {
                self.dismiss(animated: true, completion: nil)
            }
        case forwardButton:
            self.navBarDelegate?.miniAppNavigationBar(didTriggerAction: .forward)
        default:
            break
        }
    }
}
