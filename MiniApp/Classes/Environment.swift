internal protocol EnvironmentProtocol {
    var valueNotFound: String { get }
    func value(for key: String) -> String?
    func bool(for key: String) -> Bool?
}

internal class Environment {
    enum Key: String {
        case applicationIdentifier = "RASApplicationIdentifier",
        projectId = "RASProjectId",
        version = "CFBundleShortVersionString",
        subscriptionKey = "RASProjectSubscriptionKey",
        endpoint = "RMAAPIEndpoint",
        isTestMode = "RMAIsTestMode",
        hostAppUserAgentInfo = "RMAHostAppUserAgentInfo"
    }

    let bundle: EnvironmentProtocol

    var customUrl: String?
    @available(*, deprecated)
    var customAppId: String?
    var customProjectId: String?
    var customAppVersion: String?
    var customSubscriptionKey: String?
    var customIsTestMode: Bool?

    init(bundle: EnvironmentProtocol = Bundle.main) {
        self.bundle = bundle
    }

    convenience init(with config: MiniAppSdkConfig, bundle: EnvironmentProtocol = Bundle.main) {
        self.init(bundle: bundle)
        self.customUrl = config.baseUrl
        self.customAppId = config.rasAppId
        self.customProjectId = config.rasProjectId
        self.customSubscriptionKey = config.subscriptionKey
        self.customAppVersion = config.hostAppVersion
        self.customIsTestMode = config.isTestMode
    }

    @available(*, deprecated)
    var appId: String {
        return value(for: customAppId, fallback: .applicationIdentifier)
    }

    var projectId: String {
        return value(for: customProjectId, fallback: .projectId, fallbackParam: self.appId)
    }

    var appVersion: String {
        return value(for: customAppVersion, fallback: .version)
    }

    var subscriptionKey: String {
        return value(for: customSubscriptionKey, fallback: .subscriptionKey)
    }

    var isTestMode: Bool {
        return bool(for: customIsTestMode, fallback: .isTestMode)
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

    func value(for field: String?, fallback key: Key, fallbackParam: String) -> String {
        return field ?? bundle.value(for: key.rawValue) ?? fallbackParam
    }

    func bool(for field: Bool?, fallback key: Key) -> Bool {
        return field ?? bundle.bool(for: key.rawValue) ?? false
    }
}
