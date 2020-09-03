// MARK: - MiniAppNavigationConfig

/// Create a Mini App navigation UI configuration to provide MiniApp client a user interface to navigate inside the Mini App.
///
/// - Parameters:
///   - navigationBarVisibility: MiniAppNavigationVisibility enum value
///   - navigationDelegate: A delegate that will receive MiniApp view instructions about available navigation options
///   - customNavigationView: A view implementing `MiniAppNavigationDelegate` that will be overlayed to the bottom of the MiniApp view
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

// MARK: - Delegates

/// A delegate used by Mini App view to communicate about available actions based on current user interactions on the Mini App
public protocol MiniAppNavigationDelegate: class {
    func miniAppNavigation(shouldOpen url:URL, with jsonResponseHandler: @escaping (Codable) -> Void)
    func miniAppNavigation(canUse actions: [MiniAppNavigationAction])
    func miniAppNavigation(delegate: MiniAppNavigationBarDelegate)
}

/// A delegate implemented by the Mini App view to get the actions triggered by UI
public protocol MiniAppNavigationBarDelegate: class {
    /// Method to call when a user want to interact with Mini App navigation history
    ///    - action: the action requested (go back or go forward)
    /// Returns if action has been triggered or not
    @discardableResult
    func miniAppNavigationBar(didTriggerAction action: MiniAppNavigationAction) -> Bool
}

// MARK: - Enums

/// An enum used by `MiniAppNavigationBarDelegate` to indicate which action has been triggered by navigation UI
public enum MiniAppNavigationAction {
    case back, forward
}

/// An enum used to provide `MiniAppNavigationConfig` visibility option
///    - never = the UI will never be shown
///    - auto = navigation UI is only shown when a back or forward action is availablse
///    - always = navigation UI is always present
public enum MiniAppNavigationVisibility {
    case never, auto, always
}
