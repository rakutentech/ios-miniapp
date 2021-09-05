import UIKit

class RATViewController: UIViewController {
    var pageName: String?
    var siteSection: String?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if siteSection.isNilOrEmpty {
            siteSection = pageName
        }
        DemoAppAnalytics.sendAnalytics(eventType: .pageLoad, pageName: pageName, siteSection: siteSection)
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
        DemoAppAnalytics.sendAnalytics(eventType: .pageLoad, pageName: pageName, siteSection: siteSection)
    }
}
