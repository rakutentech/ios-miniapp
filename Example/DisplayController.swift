import UIKit
import MiniApp

class DisplayController: UIViewController {
    var miniAppInfo: MiniAppInfo?

    override func viewDidLoad() {
        guard let info = miniAppInfo else {
            return
        }
        self.showProgressIndicator()
        MiniApp.create(appInfo: info) { (result) in
            switch result {
            case .success(let miniAppDisplay):
                self.dismissProgressIndicator()
                let view = miniAppDisplay.getMiniAppView()
                view.frame = self.view.bounds
                self.view.addSubview(view)
            case .failure(let error):
                self.displayErrorAlert(title: "Error", message: "Downloading failed, please try again later", dismissController: true)
                print("Errored: ", error.localizedDescription)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.dismiss(animated: true, completion: nil)
                })
            }
        }
    }
}
