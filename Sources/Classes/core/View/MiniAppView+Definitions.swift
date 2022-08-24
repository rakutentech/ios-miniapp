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

public struct MiniAppConfig {
    let config: MiniAppSdkConfig?
    let adsDisplayer: MiniAppAdDisplayer?
    let messageInterface: MiniAppMessageDelegate
    let navigationDelegate: MiniAppNavigationDelegate?

    public init(
        config: MiniAppSdkConfig?,
        adsDisplayer: MiniAppAdDisplayer? = nil,
        messageInterface: MiniAppMessageDelegate,
        navigationDelegate: MiniAppNavigationDelegate? = nil
    ) {
        self.config = config
        self.adsDisplayer = adsDisplayer
        self.messageInterface = messageInterface
        self.navigationDelegate = navigationDelegate
    }
}

public struct MiniAppViewDefaultParams {
    let config: MiniAppConfig
    let type: MiniAppType
    let appId: String
    let version: String?
    let queryParams: String?

    public init(
        config: MiniAppConfig,
        type: MiniAppType,
        appId: String,
        version: String? = nil,
        queryParams: String? = nil
    ) {
        self.config = config
        self.type = type
        self.appId = appId
        self.version = version
        self.queryParams = queryParams
    }
}

public struct MiniAppViewUrlParams {
    let config: MiniAppConfig
    let type: MiniAppType
    let url: URL
    let queryParams: String?

    public init(config: MiniAppConfig, type: MiniAppType, url: URL, queryParams: String? = nil) {
        self.config = config
        self.type = type
        self.url = url
        self.queryParams = queryParams
    }
}
