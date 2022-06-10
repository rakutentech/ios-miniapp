import Foundation
import UIKit

public class MiniAppCustomNavigationController: UINavigationController {
    /// When UIDocumentPickerViewController or UIActivityController is dismissed, parent view is also getting dismissed. This seem like a bug in SDK so we are making sure
    /// here to dismiss only once.
    open override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        if let controller = self.presentedViewController,
           controller.isKind(of: UIDocumentPickerViewController.self) || controller.isKind(of: UIActivityViewController.self) {
             if !controller.isBeingDismissed {
                super.dismiss(animated: flag, completion: completion)
            }
        } else {
            super.dismiss(animated: flag, completion: completion)
        }
    }
}

public class MiniAppActivityController: UIActivityViewController {
    public override init(activityItems: [Any], applicationActivities: [UIActivity]?) {
        super.init(activityItems: activityItems, applicationActivities: applicationActivities)
        completionWithItemsHandler = { (type, completed: Bool, _, _) in
            if type == nil && !completed {
                super.dismiss(animated: true, completion: nil)
            }
        }
    }

    public override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        if let completion = completion {
            completion()
        } else {
            super.dismiss(animated: flag, completion: completion)
        }
    }
}

