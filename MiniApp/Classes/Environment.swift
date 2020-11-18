internal protocol EnvironmentProtocol {
    var valueNotFound: String { get }
    func value(for key: String) -> String?
    func bool(for key: String) -> Bool?
}

internal class Environment {
    enum Key: String {
        case applicationIdentifier = "RASApplicationIdentifier",
            version = "CFBundleShortVersionString",
            subscriptionKey = "RASProjectSubscriptionKey",
            endpoint = "RMAAPIEndpoint",
            isPreviewMode = "RMAIsPreviewMode",
            isTestMode = "RMAIsTestMode",
            hostAppUserAgentInfo = "RMAHostAppUserAgentInfo"
    }

    let bundle: EnvironmentProtocol

    var customUrl: String?
    var customAppId: String?
    var customAppVersion: String?
    var customSubscriptionKey: String?
    var customIsPreviewMode: Bool?
    @available(*, deprecated, renamed: "customIsPreviewMode")
    var customIsTestMode: Bool?

    init(bundle: EnvironmentProtocol = Bundle.main) {
        self.bundle = bundle
    }

    convenience init(with config: MiniAppSdkConfig, bundle: EnvironmentProtocol = Bundle.main) {
        self.init(bundle: bundle)
        self.customUrl = config.baseUrl
        self.customAppId = config.rasAppId
        self.customSubscriptionKey = config.subscriptionKey
        self.customAppVersion = config.hostAppVersion
        self.customIsPreviewMode = config.isPreviewMode
    }

    var appId: String {
        return value(for: customAppId, fallback: .applicationIdentifier)
    }

    var appVersion: String {
        return value(for: customAppVersion, fallback: .version)
    }

    var subscriptionKey: String {
        return value(for: customSubscriptionKey, fallback: .subscriptionKey)
    }

    var isPreviewMode: Bool {
        return bool(for: customIsPreviewMode, fallback: .isPreviewMode)
    }

    @available(*, deprecated, renamed: "isPreviewMode", message: "`isTestMode` is deprecated. If it has no defined value it will return value from `isPreviewMode`")
    var isTestMode: Bool {
        MiniAppLogger.w("`isTestMode` is deprecated. If it has no defined value it will return value from `isPreviewMode`")
        return bool(for: customIsTestMode, fallback: .isPreviewMode)
    }

    var hostAppUserAgentInfo: String {
        return bundle.value(for: Key.hostAppUserAgentInfo.rawValue) ?? bundle.valueNotFound
    }

    var baseUrl: URL? {
        let defaultEndpoint = bundle.value(for: Key.endpoint.rawValue)
        guard let endpointUrlString = (self.customUrl ?? defaultEndpoint) else {
            MiniAppLogger.e("Ensure RMAAPIEndpoint value in plist is valid")
            return nil
        }
        return URL(string: "\(endpointUrlString)")
    }

    func value(for field: String?, fallback key: Key) -> String {
        return field ?? bundle.value(for: key.rawValue) ?? bundle.valueNotFound
    }

    func bool(for field: Bool?, fallback key: Key) -> Bool {
        return field ?? bundle.bool(for: key.rawValue) ?? false
    }
}
