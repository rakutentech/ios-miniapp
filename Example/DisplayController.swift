import UIKit
import MiniApp

class DisplayController: UIViewController {

    var config: MiniAppSdkConfig?

    override func viewWillAppear(_ animated: Bool) {
        config = Config.getCurrent()
    }

    override func viewDidAppear(_ animated: Bool) {
        guard let controller = self.navigationController as? DisplayNavigationController, let info = controller.miniAppInfo, let miniAppDisplay = controller.miniAppDisplay else {
            return
        }

        self.title = info.displayName

        let view = miniAppDisplay.getMiniAppView()
        view.frame = self.view.bounds
        self.view.addSubview(view)
    }

    @IBAction func done(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
