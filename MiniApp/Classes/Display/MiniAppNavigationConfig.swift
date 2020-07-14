public protocol MiniAppNavigationDelegate: class {
    func miniAppNavigation(canUse actions: [MiniAppNavigationAction])
    func miniAppNavigation(delegate: MiniAppNavigationBarDelegate)
}

public protocol MiniAppNavigationBarDelegate: class {
    func miniAppNavigationBar(_ navBar: UIView & MiniAppNavigationDelegate, didTriggerAction action: MiniAppNavigationAction)
}

public enum MiniAppNavigationAction {
    case back, forward
}

public enum MiniAppNavigationVisibility {
    case never, auto, always
}

public class MiniAppNavigationConfig {
    var navigationBarVisibility: MiniAppNavigationVisibility? = .never
    weak var navigationDelegate: MiniAppNavigationDelegate?
    var navigationView: (UIView & MiniAppNavigationDelegate)?

    public init(
        navigationBarVisibility: MiniAppNavigationVisibility? = .never,
        navigationDelegate: MiniAppNavigationDelegate? = nil,
        customNavigationView: (UIView & MiniAppNavigationDelegate)? = nil) {
        self.navigationBarVisibility = navigationBarVisibility
        self.navigationDelegate = navigationDelegate
        self.navigationView = customNavigationView
    }
}
