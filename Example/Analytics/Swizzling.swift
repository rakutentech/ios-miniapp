import UIKit

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
                                       elementType: self.classForCoder.description())
    }

    @objc func buttonClicked () {
        let controller = UINavigationController.topViewController() as? RATViewController
        DemoAppAnalytics.sendAnalytics(eventType: .click,
                                       actionType: .open,
                                       pageName: controller?.pageName,
                                       siteSection: controller?.siteSection,
                                       componentName: self.titleLabel?.text,
                                       elementType: self.classForCoder.description())
    }
}

extension UIControl {

    static func swizzleSendAction() {
        let originalSelector = #selector(UIControl.sendAction(_:to:for:))
        let swizzledSelector = #selector(UIControl.swapSendAction(_:to:forEvent:))
        let originalMethod = class_getInstanceMethod(UIControl.self, originalSelector)!
        let swizzledMethod = class_getInstanceMethod(UIControl.self, swizzledSelector)!
        let didAddMethod = class_addMethod(UIControl.self,
                                           originalSelector,
                                           method_getImplementation(swizzledMethod),
                                           method_getTypeEncoding(swizzledMethod))
        if didAddMethod {
            class_replaceMethod(UIControl.self,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }

    // MARK: - Method Swizzling
    @objc private func swapSendAction(_ action: Selector, to target: AnyObject?, forEvent event: UIEvent?) {
        guard let barButtonItem = target?.barButtonItem as? UIBarButtonItem else {
            return
        }
        trackBarButtonItem(eventType: .click, actionType: .open, componentName: barButtonItem.title ?? "", elementType: barButtonItem.classForCoder.description())
        _ = target?.perform(action, with: self, with: UIEvent())
    }

    private func trackBarButtonItem(eventType: DemoAppRATEventType, actionType: DemoAppRATActionType, componentName: String, elementType: String) {
        let controller = UINavigationController.topViewController() as? RATViewController
        DemoAppAnalytics.sendAnalytics(eventType: .appear,
                                       actionType: .initial,
                                       pageName: controller?.pageName,
                                       siteSection: controller?.siteSection,
                                       componentName: componentName,
                                       elementType: elementType)
    }
}
