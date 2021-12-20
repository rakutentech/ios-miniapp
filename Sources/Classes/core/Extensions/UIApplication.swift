extension UIApplication {
  func keyWindow() -> UIWindow? {
      return windows.filter { $0.isKeyWindow }.first
  }

  class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow()?.topController()) -> UIViewController? {
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
