import Foundation
import UIKit

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
