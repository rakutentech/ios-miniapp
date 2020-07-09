import Foundation

public protocol MiniAppNavigationDelegate: class {
    func miniAppNavigation(canUse actions: [MiniAppNavigationAction])
    func miniAppNavigation(didTrigger action: MiniAppNavigationAction)
}

public enum MiniAppNavigationAction {
    case back, forward
}

public enum MiniAppNavigationVisibility {
    case never, auto, always
}

public class MiniAppNavigationConfig {
    var navigationBarVisibility: MiniAppNavigationVisibility? = .auto
    var navigationDelegate: MiniAppNavigationDelegate? = nil
    var navigationView: (UIView & MiniAppNavigationDelegate)? = nil

    public init(navigationBarVisibility: MiniAppNavigationVisibility? = .auto,
                navigationDelegate: MiniAppNavigationDelegate? = nil,
                customNavigationView: (UIView & MiniAppNavigationDelegate)? = nil) {
        self.navigationBarVisibility = navigationBarVisibility
        self.navigationDelegate = navigationDelegate
        self.navigationView = customNavigationView
    }
}