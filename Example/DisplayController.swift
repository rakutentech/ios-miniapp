import UIKit
import MiniApp

class DisplayController: UIViewController {
    var config: MiniAppSdkConfig?

    override func viewWillAppear(_ animated: Bool) {
        config = Config.getCurrent()
    }

    override func viewDidAppear(_ animated: Bool) {
        guard let controller = self.navigationController as? DisplayNavigationController, let info = controller.miniAppInfo else {
            return
        }

        self.showProgressIndicator()
        self.title = info.displayName
        MiniApp.shared(with: config).create(appInfo: info) { (result) in
            switch result {
            case .success(let miniAppDisplay):
                self.dismissProgressIndicator()
                let view = miniAppDisplay.getMiniAppView()
                view.frame = self.view.bounds
                self.view.addSubview(view)
            case .failure(let error):
                self.displayAlert(title: NSLocalizedString("error_title", comment: ""), message: NSLocalizedString("error_miniapp_download_message", comment: ""), dismissController: true)
                print("Errored: ", error.localizedDescription)
            }
        }
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
