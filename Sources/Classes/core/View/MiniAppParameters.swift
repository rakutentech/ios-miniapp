import Foundation

// MiniAppViewParameters used to initalize MiniAppView
public enum MiniAppViewParameters {
    /// The default init config which uses `appId` and `version` to initalize the MiniApp
    case `default`(DefaultParams)
    /// The url config which uses `url` to initalize the MiniApp
    case url(UrlParams)
    /// The init to initalize the MiniApp with MiniAppInfo
    case info(InfoParams)
}

public extension MiniAppViewParameters {

    /// MiniAppView default parameters
    struct DefaultParams {
        let config: MiniAppConfig
        let type: MiniAppType
        let appId: String
        let version: String?
        let queryParams: String?
        var fromBundle: Bool? = false

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
            queryParams: String? = nil,
            fromBundle: Bool? = false
        ) {
            self.config = config
            self.type = type
            self.appId = appId
            self.version = version
            self.queryParams = queryParams
            self.fromBundle = fromBundle
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

    /// MiniAppView info parameters
    struct InfoParams {
        let config: MiniAppConfig
        let type: MiniAppType
        let info: MiniAppInfo
        let queryParams: String?
        var fromBundle: Bool? = false

        /**
        Initializes url parameters for MiniAppView

        - Parameters:
            - config: MiniAppConfig that defines the basic config necessary for MiniAppView
            - type: The type of the MiniApp
            - info: The info that will be used to load the MiniApp
            - queryParams: The query parameters of the MiniApp (optional)
         */
        public init(
            config: MiniAppConfig,
            type: MiniAppType,
            info: MiniAppInfo,
            queryParams: String? = nil,
            fromBundle: Bool? = false
        ) {
            self.config = config
            self.type = type
            self.info = info
            self.queryParams = queryParams
            self.fromBundle = fromBundle
        }
    }
}
