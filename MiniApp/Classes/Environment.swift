internal protocol EnvironmentProtocol {
    var valueNotFound: String { get }
    func value(for key: String) -> String?
}

internal class Environment {
    enum Key: String {
        case applicationIdentifier = "RASApplicationIdentifier",
            version = "CFBundleShortVersionString",
            subscriptionKey = "RASProjectSubscriptionKey",
            endpoint = "RMAAPIEndpoint",
            testEndpoint = "RMAAPITestEndpoint"
    }

    let bundle: EnvironmentProtocol

    var customUrl: String?
    var customAppId: String?
    var customAppVersion: String?
    var customSubscriptionKey: String?
    var loadTestVersions: Bool?

    init(bundle: EnvironmentProtocol = Bundle.main) {
        self.bundle = bundle
    }

    convenience init(with config: MiniAppSdkConfig, bundle: EnvironmentProtocol = Bundle.main) {
        self.init(bundle: bundle)
        self.customUrl = config.url
        self.customAppId = config.rasAppId
        self.customSubscriptionKey = config.subscriptionKey
        self.customAppVersion = config.hostAppVersion
        self.loadTestVersions = config.loadTestVersions
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

    var baseUrl: URL? {
        let defaultEndpoint = loadTestVersions ?? false ? (bundle.value(for: Key.testEndpoint.rawValue)) : (bundle.value(for: Key.endpoint.rawValue))
        guard let endpointUrlString = (self.customUrl ?? defaultEndpoint) else {
            MiniAppLogger.e("Ensure RMAAPIEndpoint and RMAAPITestEndpoint values in plist are valid")
            return nil
        }
        return URL(string: "\(endpointUrlString)")
    }

    func value(for field: String?, fallback key: Key) -> String {
        return field ?? bundle.value(for: key.rawValue) ?? bundle.valueNotFound
    }
}
