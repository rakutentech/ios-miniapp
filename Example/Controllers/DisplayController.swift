import UIKit
import MiniApp
import AVKit

class DisplayController: UIViewController {

    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var forwardButton: UIBarButtonItem!
    weak var navBarDelegate: MiniAppNavigationBarDelegate?
    weak var miniAppDisplayDelegate: MiniAppDisplayProtocol?
    static var miniAppSupportedOrientation: UIInterfaceOrientationMask = []

    override func viewDidAppear(_ animated: Bool) {
        guard let controller = self.navigationController as? DisplayNavigationController, let info = controller.miniAppInfo, let miniAppDisplay = controller.miniAppDisplay else {
            return
        }

        self.title = info.displayName
        self.miniAppDisplayDelegate = miniAppDisplay
        let view = miniAppDisplay.getMiniAppView()
        view.frame = self.view.bounds
        self.navBarDelegate = miniAppDisplay as? MiniAppNavigationBarDelegate
        self.view.addSubview(view)
        self.navigationController?.delegate = self
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

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        DisplayController.miniAppSupportedOrientation = self.miniAppDisplayDelegate?.getSupportedOrientation() ?? .all
        return DisplayController.miniAppSupportedOrientation
    }
}

extension DisplayController: UINavigationControllerDelegate {
    public func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return navigationController.topViewController?.supportedInterfaceOrientations ?? .all
    }
}

extension AVPlayerViewController {
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return DisplayController.miniAppSupportedOrientation
    }
}
