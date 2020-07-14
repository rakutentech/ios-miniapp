import UIKit
import MiniApp

class CustomNavigationView: UIView {
    weak var delegate: MiniAppNavigationBarDelegate?
    @IBOutlet var backButton: UIButton!

    @IBAction func actionGoBack() {
        delegate?.miniAppNavigationBar(self, didTriggerAction: .back)
    }
}

extension CustomNavigationView: MiniAppNavigationDelegate {
    func miniAppNavigation(delegate: MiniAppNavigationBarDelegate) {
        self.delegate = delegate
    }

    func miniAppNavigation(canUse actions: [MiniAppNavigationAction]) {

    }
}
