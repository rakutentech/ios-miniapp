import UIKit

class RATViewController: UIViewController {
    var pageName: String?
    var siteSection: String?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if siteSection.isNilOrEmpty {
            siteSection = pageName
        }
        DemoAppAnalytics.sendAnalytics(eventType: .pageLoad,
                                       pageName: pageName,
                                       siteSection: siteSection,
                                       componentName: "View Controller")
    }
}

class RATViewControllerWithTableView: RATViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DemoAppAnalytics.sendAnalyticsForCell(eventType: .appear, actionType: .initial, cell: cell)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        DemoAppAnalytics.sendAnalyticsForCell(eventType: .click, actionType: .open, cell: cell)
    }
}

class RATTableViewController: UITableViewController {
    var pageName: String?
    var siteSection: String?

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if siteSection.isNilOrEmpty {
            siteSection = pageName
        }
        DemoAppAnalytics.sendAnalytics(eventType: .pageLoad,
                                       pageName: pageName,
                                       siteSection: siteSection,
                                       componentName: "Table View Controller")
    }
}

extension UIButton {
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.addTarget(self, action: #selector(buttonClicked), for: .touchDown)
        let controller = UINavigationController.topViewController() as? RATViewController
        DemoAppAnalytics.sendAnalytics(eventType: .appear,
                                       actionType: .initial,
                                       pageName: controller?.pageName,
                                       siteSection: controller?.siteSection,
                                       componentName: self.titleLabel?.text,
                                       elementType: "Button")
    }

    @objc func buttonClicked () {
        let controller = UINavigationController.topViewController() as? RATViewController
        DemoAppAnalytics.sendAnalytics(eventType: .click,
                                       actionType: .open,
                                       pageName: controller?.pageName,
                                       siteSection: controller?.siteSection,
                                       componentName: self.titleLabel?.text,
                                       elementType: "Button")
    }
}
