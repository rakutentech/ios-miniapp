import Foundation

/// MiniAppViewState that indicates in which state the view is when eg. loading the MiniApp
enum MiniAppViewState {
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
        - messageDelegate: Message delegate to handle getUniqueId etc
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

public enum MiniAppViewParameters {
    case `default`(MiniAppView.DefaultParams)
    case url(MiniAppView.UrlParams)
    case info(MiniAppView.InfoParams) // check with munir
}

public extension MiniAppView {

    /// MiniAppView default parameters
    struct DefaultParams {
        let config: MiniAppConfig
        let type: MiniAppType
        let appId: String
        let version: String?
        let queryParams: String?

        /**
        Initializes default parameters for MiniAppView

        - Parameters:
            - config: MiniAppConfig that defines the basic config necessary for MiniAppView
            - type: The type of the MiniApp
            - appId: The appId of the MiniApp
            - version: The version of the MiniApp (optional)
            - queryParams: The query parameters of the MiniApp (optional)
         */
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

    /// MiniAppView url parameters
    struct UrlParams {
        let config: MiniAppConfig
        let type: MiniAppType
        let url: URL
        let queryParams: String?

        /**
        Initializes url parameters for MiniAppView

        - Parameters:
            - config: MiniAppConfig that defines the basic config necessary for MiniAppView
            - type: The type of the MiniApp
            - url: The url that will be used to load the MiniApp
            - queryParams: The query parameters of the MiniApp (optional)
         */
        public init(
            config: MiniAppConfig,
            type: MiniAppType,
            url: URL,
            queryParams: String? = nil
        ) {
            self.config = config
            self.type = type
            self.url = url
            self.queryParams = queryParams
        }
    }

    struct InfoParams {
        let config: MiniAppConfig
        let type: MiniAppType
        let info: MiniAppInfo
        let queryParams: String?

        /**
        Initializes url parameters for MiniAppView

        - Parameters:
            - config: MiniAppConfig that defines the basic config necessary for MiniAppView
            - type: The type of the MiniApp
            - info: The MiniAppInfo used to load the MiniApp
            - queryParams: The query parameters of the MiniApp (optional)
         */
        public init(
            config: MiniAppConfig,
            type: MiniAppType,
            info: MiniAppInfo,
            queryParams: String? = nil
        ) {
            self.config = config
            self.type = type
            self.info = info
            self.queryParams = queryParams
        }
    }
}
