import UIKit
import MiniApp

class DisplayController: UIViewController {

    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var forwardButton: UIBarButtonItem!
    weak var navBarDelegate: MiniAppNavigationBarDelegate?
    weak var miniAppDisplayDelegate: MiniAppDisplayDelegate?

    override func viewDidAppear(_ animated: Bool) {
        guard let controller = self.navigationController as? DisplayNavigationController,
              let miniAppDisplay = controller.miniAppDisplay else {
            return
        }

        title = controller.miniAppInfo?.displayName ?? "Mini app"
        miniAppDisplayDelegate = miniAppDisplay
        let miniAppView = miniAppDisplay.getMiniAppView()
        miniAppView.frame = view.bounds
        navBarDelegate = miniAppDisplay as? MiniAppNavigationBarDelegate
        view.addSubview(miniAppView)
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
