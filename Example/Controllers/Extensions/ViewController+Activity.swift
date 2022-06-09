import Foundation
import UIKit

public class MiniAppActivityController: UIActivityViewController {
    public override init(activityItems: [Any], applicationActivities: [UIActivity]?) {
        super.init(activityItems: activityItems, applicationActivities: applicationActivities)
        completionWithItemsHandler = { (activityType, completed: Bool, returnedItems:[Any]?, error: Error?) in
            if !completed {
                super.dismiss(animated: true, completion: nil)
            }
        }
    }

    public override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        completion?()
    }
}
