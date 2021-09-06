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
