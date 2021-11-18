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
                                       componentName: pageName,
                                       elementType: "View Controller")
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            DemoAppAnalytics.sendAnalytics(eventType: .click,
                                           actionType: .close,
                                           pageName: pageName,
                                           siteSection: siteSection,
                                           componentName: "Back",
                                           elementType: "View Controller")
        }
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
        DemoAppAnalytics.sendAnalyticsForCell(eventType: .appear,
                                              actionType: .initial,
                                              pageName: self.pageName ?? "",
                                              siteSection: self.siteSection ?? "",
                                              cell: cell)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        DemoAppAnalytics.sendAnalyticsForCell(eventType: .click,
                                              actionType: .open,
                                              pageName: self.pageName ?? "",
                                              siteSection: self.siteSection ?? "",
                                              cell: cell)
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            DemoAppAnalytics.sendAnalytics(eventType: .click,
                                           actionType: .close,
                                           pageName: pageName,
                                           siteSection: siteSection,
                                           componentName: "Back",
                                           elementType: "Table View Controller")
        }
    }
}

class RATTableViewController: UITableViewController {
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
                                       componentName: pageName,
                                       elementType: "Table View Controller")
    }
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            DemoAppAnalytics.sendAnalytics(eventType: .click,
                                           actionType: .close,
                                           pageName: pageName,
                                           siteSection: siteSection,
                                           componentName: "Back",
                                           elementType: "Table View Controller")
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        DemoAppAnalytics.sendAnalyticsForCell(eventType: .click,
                                              actionType: .open,
                                              pageName: self.pageName ?? "",
                                              siteSection: self.siteSection ?? "",
                                              cell: cell)
    }
}

extension UIButton {
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.addTarget(self, action: #selector(buttonClicked), for: .touchDown)
        let controller = getPageDetails()
        DemoAppAnalytics.sendAnalytics(eventType: .appear,
                                       actionType: .initial,
                                       pageName: controller.pageName,
                                       siteSection: controller.siteSection,
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

extension UISegmentedControl {
    open override func sendActions(for controlEvents: UIControl.Event) {
        super.sendActions(for: controlEvents)
        let controller = getPageDetails()
        DemoAppAnalytics.sendAnalytics(eventType: .click,
                                       actionType: .changeStatus,
                                       pageName: controller.pageName,
                                       siteSection: controller.siteSection,
                                       componentName: self.titleForSegment(at: self.selectedSegmentIndex),
                                       elementType: "UISegmentedControl")
    }
}

private func getPageDetails() -> (pageName: String?, siteSection: String?) {
    guard let controller = UINavigationController.topViewController() as? RATViewController else {
        guard let tableViewController = UINavigationController.topViewController() as? RATTableViewController else {
            guard let viewControllerWithTableView   = UINavigationController.topViewController() as? RATViewControllerWithTableView else {
                return ("", "")
            }
            return (viewControllerWithTableView.pageName, viewControllerWithTableView.siteSection)
        }
        return (tableViewController.pageName, tableViewController.siteSection)
    }
    return (controller.pageName, controller.siteSection)
}
