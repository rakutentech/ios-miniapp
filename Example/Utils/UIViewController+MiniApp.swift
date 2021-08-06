import Foundation
import UIKit

extension UIViewController {
    var tintColor: UIColor {
        UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.tintColor ?? #colorLiteral(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
    }

    class func topViewController(controller: UIViewController? = UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController) -> UIViewController? {
        if let tabController = controller as? UITabBarController {
          return topViewController(controller: tabController.selectedViewController)
        }
        if let navController = controller as? UINavigationController {
          return topViewController(controller: navController.visibleViewController)
        }
        if let presented = controller?.presentedViewController {
          return topViewController(controller: presented)
        }
        return controller
    }
}
