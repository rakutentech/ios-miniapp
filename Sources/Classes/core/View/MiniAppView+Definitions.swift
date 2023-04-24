import Foundation
import UIKit

/// MiniAppViewState that indicates in which state the view is when eg. loading the MiniApp
public enum MiniAppViewState {
    case none
    case loading
    case active
    case inactive
    case error(Error)
}

/// MiniApp's type which can be `.miniapp` or `.widget`. Widgets will provide reduced functionality and no user interaction.
public enum MiniAppType {
    case miniapp
    case widget
}

/// Base config to initialize a MiniAppView
public struct MiniAppConfig {
    let config: MiniAppSdkConfig?
    let adsDisplayer: MiniAppAdDisplayer?
    let messageDelegate: MiniAppMessageDelegate
    let navigationDelegate: MiniAppNavigationDelegate?

    /**
    Initializes a new config for MiniAppView

    - Parameters:
        - config: MiniAppSdkConfig that defines the baseUrl and other basic settings
        - adsDisplayer: Ads Displayer for showing ads
        - messageDelegate: Message delegate to handle different interface callbacks used by Mini App to communicate with the Native implementation.
        - navigationDelegate: Handling of webview navigation actions
     */
    public init(
        config: MiniAppSdkConfig?,
        adsDisplayer: MiniAppAdDisplayer? = nil,
        messageDelegate: MiniAppMessageDelegate,
        navigationDelegate: MiniAppNavigationDelegate? = nil
    ) {
        self.config = config
        self.adsDisplayer = adsDisplayer
        self.messageDelegate = messageDelegate
        self.navigationDelegate = navigationDelegate
    }
}

public protocol MiniAppProgressViewable: UIView {
    func updateViewState(state: MiniAppViewState)
}
