import UIKit

public extension UIWindow {
    func topController() -> UIViewController? {
        if var topController = rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }

            return topController
        } else {
            return nil
        }
    }
}
