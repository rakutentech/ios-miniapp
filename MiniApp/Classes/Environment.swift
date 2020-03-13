internal protocol EnvironmentProtocol {
    var valueNotFound: String { get }
    func value(for key: String) -> String?
}

internal class Environment {
    enum Key: String {
        case applicationIdentifier = "RASApplicationIdentifier",
            version = "CFBundleShortVersionString",
            subscriptionKey = "RASProjectSubscriptionKey",
            endpoint = "RMAAPIEndpoint"
    }

    let bundle: EnvironmentProtocol

    var customUrl: String?
    var customAppId: String?
    var customAppVersion: String?
    var customSubscriptionKey: String?

    init(bundle: EnvironmentProtocol = Bundle.main) {
        self.bundle = bundle
    }

    convenience init(with config: MiniAppSdkConfig, bundle: EnvironmentProtocol = Bundle.main) {
        self.init(bundle: bundle)
        self.customUrl = config.baseUrl
        self.customAppId = config.rasAppId
        self.customSubscriptionKey = config.subscriptionKey
        self.customAppVersion = config.hostAppVersion
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
        guard let endpointUrlString = (self.customUrl ?? bundle.value(for: Key.endpoint.rawValue)) else {
            MiniAppLogger.e("Ensure RMAAPIEndpoint value in plist is valid")
            return nil
        }
        return URL(string: "\(endpointUrlString)")
    }

    func value(for field: String?, fallback key: Key) -> String {
        return field ?? bundle.value(for: key.rawValue) ?? bundle.valueNotFound
    }
}
