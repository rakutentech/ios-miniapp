import UIKit
import MiniApp

class GeneralTableViewController: RATTableViewController {
    override func viewDidLoad() {
        self.pageName = MASDKLocale.localize("demo.app.rat.page.name.general")
    }
}
