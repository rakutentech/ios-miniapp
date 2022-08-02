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

    public init(config: MiniAppSdkConfig?, adsDisplayer: AdMobDisplayer?, messageInterface: MiniAppMessageDelegate) {
        self.config = config
        self.adsDisplayer = adsDisplayer
        self.messageInterface = messageInterface
    }
}
