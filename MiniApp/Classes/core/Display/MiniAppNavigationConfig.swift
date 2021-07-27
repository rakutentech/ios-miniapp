import UIKit

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
public typealias MiniAppNavigationResponseHandler = (URL) -> Void

/// A delegate used by Mini App view to communicate about available actions based on current user interactions on the Mini App
public protocol MiniAppNavigationDelegate: class {
    /// This delegate method is called when an external URL is tapped into a Mini App
    /// so you can display your own webview to load the url parameter, for example.
    /// A `MiniAppNavigationResponseHandler` is also provided so you can give a proper
    /// feedback to your MiniApp under the form of an URL when you want
    /// - Parameters:
    ///   - url: the external URL triggered from the MiniApp
    ///   - responseHandler: a `MiniAppNavigationResponseHandler` used to provide an URL to the Mini App
    func miniAppNavigation(shouldOpen url: URL, with responseHandler: @escaping MiniAppNavigationResponseHandler)
    /// This delegate method is called when an external URL is tapped into a url loaded Mini App
    /// so you can display your own webview to load the url parameter, for example.
    /// A `MiniAppNavigationResponseHandler` is also provided so you can give a proper
    /// feedback to your MiniApp under the form of an URL when you want.
    /// This should only be used for previewing a mini app from a local server.
    /// - Parameters:
    ///   - url: the external URL triggered from the MiniApp
    ///   - responseHandler: a `MiniAppNavigationResponseHandler` used to provide an URL to the Mini App
    ///   - customMiniAppURL: The url that was used to load the Mini App.
    func miniAppNavigation(shouldOpen url: URL, with responseHandler: @escaping MiniAppNavigationResponseHandler, customMiniAppURL: URL)
    /// This delegate method is called when a navigation is performed inside the Mini App.
    /// - Parameters:
    ///   - actions: a list of `MiniAppNavigationAction` that can be used to navigate inside the Mini App
    func miniAppNavigation(canUse actions: [MiniAppNavigationAction])
    /// This delegate method is called when a Mini App view is created.
    /// - Parameters:
    ///   - delegate: a`MiniAppNavigationBarDelegate` the can be used to call `MiniAppNavigationAction` on the Mini App view
    func miniAppNavigation(delegate: MiniAppNavigationBarDelegate)

    func canMiniAppNavigateTo(action: MiniAppNavigationAction) -> Bool
}

public extension MiniAppNavigationDelegate {
    func miniAppNavigation(shouldOpen url: URL, with responseHandler: @escaping MiniAppNavigationResponseHandler) {
        MiniAppExternalWebViewController.presentModally(url: url,
                                                        externalLinkResponseHandler: responseHandler,
                                                        customMiniAppURL: nil)
    }
    func miniAppNavigation(shouldOpen url: URL,
                           with responseHandler: @escaping MiniAppNavigationResponseHandler,
                           customMiniAppURL: URL) {
        MiniAppExternalWebViewController.presentModally(url: url,
                                                        externalLinkResponseHandler: responseHandler,
                                                        customMiniAppURL: customMiniAppURL)
    }
    func miniAppNavigation(canUse actions: [MiniAppNavigationAction]) {
    }
    func miniAppNavigation(delegate: MiniAppNavigationBarDelegate) {
    }
}

/// A delegate implemented by the Mini App view to get the actions triggered by UI
public protocol MiniAppNavigationBarDelegate: class {
    /// Method to call when a user want to interact with Mini App navigation history
    /// - Parameters:
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
