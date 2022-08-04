import Foundation

enum MiniAppViewState {
    case none
    case loading
    case active
    case inactive
    case error(Error)
}

public enum MiniAppType {
    case miniapp
    case widget
}

public struct MiniAppNewConfig {
    let config: MiniAppSdkConfig?
    let adsDisplayer: AdMobDisplayer?
    let messageInterface: MiniAppMessageDelegate
    let navigationDelegate: MiniAppNavigationDelegate?

    public init(
        config: MiniAppSdkConfig?,
        adsDisplayer: AdMobDisplayer?,
        messageInterface: MiniAppMessageDelegate,
        navigationDelegate: MiniAppNavigationDelegate? = nil
    ) {
        self.config = config
        self.adsDisplayer = adsDisplayer
        self.messageInterface = messageInterface
        self.navigationDelegate = navigationDelegate
    }
}
