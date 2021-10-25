internal protocol EnvironmentProtocol {
    var valueNotFound: String { get }
    func value(for key: String) -> String?
    func bool(for key: String) -> Bool?
    func object(forInfoDictionaryKey: String) -> Any?
}

internal class Environment {
    enum Key: String {
        case applicationIdentifier = "RASApplicationIdentifier"
        case projectId = "RASProjectId"
        case version = "CFBundleShortVersionString"
        case subscriptionKey = "RASProjectSubscriptionKey"
        case endpoint = "RMAAPIEndpoint"
        case isPreviewMode = "RMAIsPreviewMode"
        case hostAppUserAgentInfo = "RMAHostAppUserAgentInfo"
        case requireMiniAppSignatureVerification = "RMARequireMiniAppSignatureVerification"
        case sslKeyHash = "RMASSLKeyHash"
        case host = "RMAAPIHost"
    }

    let bundle: EnvironmentProtocol

    var customUrl: String?
    var customSSLKeyHash: String?
    var customSSLKeyHashBackup: String?
    var customProjectId: String?
    var customAppVersion: String?
    var customSubscriptionKey: String?
    var customIsPreviewMode: Bool?
    var customSignatureVerification: Bool?

    init(bundle: EnvironmentProtocol = Bundle.main) {
        self.bundle = bundle
    }

    convenience init(with config: MiniAppSdkConfig, bundle: EnvironmentProtocol = Bundle.main) {
        self.init(bundle: bundle)
        customUrl = config.baseUrl
        customSSLKeyHash = config.sslKeyHash?.pin
        customSSLKeyHashBackup = config.sslKeyHash?.backupPin
        customProjectId = config.rasProjectId
        customSubscriptionKey = config.subscriptionKey
        customAppVersion = config.hostAppVersion
        customIsPreviewMode = config.isPreviewMode
        customSignatureVerification = config.requireMiniAppSignatureVerification
    }

    var projectId: String {
        value(for: customProjectId, fallback: .projectId)
    }

    var appVersion: String {
        value(for: customAppVersion, fallback: .version)
    }

    var sdkVersion: MiniAppVersion? {
        MiniAppVersion(string: MiniAppAnalytics.sdkVersion)
    }

    var subscriptionKey: String {
        value(for: customSubscriptionKey, fallback: .subscriptionKey)
    }

    var isPreviewMode: Bool {
        bool(for: customIsPreviewMode, fallback: .isPreviewMode)
    }

    var requireMiniAppSignatureVerification: Bool {
        bool(for: customSignatureVerification, fallback: .requireMiniAppSignatureVerification)
    }

    var hostAppUserAgentInfo: String {
        bundle.value(for: Key.hostAppUserAgentInfo.rawValue) ?? bundle.valueNotFound
    }

    var baseUrl: URL? {
        let defaultEndpoint = bundle.value(for: Key.endpoint.rawValue)
        guard let endpointUrlString = (self.customUrl ?? defaultEndpoint) else {
            MiniAppLogger.e("Ensure RMAAPIEndpoint value in plist is valid")
            return nil
        }
        return URL(string: "\(endpointUrlString)")
    }

    var host: String {
        guard let bundleHost = bundle.value(for: Key.host.rawValue) else {
            if let url = baseUrl, let comp = URLComponents(url: url, resolvingAgainstBaseURL: false), let host = comp.host {
                return host
            }
            return bundle.valueNotFound
        }
        return bundleHost
    }

    var sslKeyHash: String? {
        customSSLKeyHash
    }

    var sslKeyHashBackup: String? {
        customSSLKeyHashBackup
    }

    func value(for field: String?, fallback key: Key) -> String {
        field ?? bundle.value(for: key.rawValue) ?? bundle.valueNotFound
    }

    func value(for field: String?, fallback key: Key, fallbackParam: String) -> String {
        field ?? bundle.value(for: key.rawValue) ?? fallbackParam
    }

    func bool(for field: Bool?, fallback key: Key) -> Bool {
        field ?? bundle.bool(for: key.rawValue) ?? false
    }

    func dictionary(for key: Key) -> [String: Any?]? {
        bundle.object(forInfoDictionaryKey: key.rawValue) as? [String: Any?]
    }
}
