internal protocol EnvironmentProtocol {
    var valueNotFound: String { get }
    func value(for key: String) -> String?
}

internal class Environment {
    enum keys: String {
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

    var appId: String {
        return customAppId ?? bundle.value(for: keys.applicationIdentifier.rawValue) ?? bundle.valueNotFound
    }

    var appVersion: String {
        return customAppVersion ?? bundle.value(for: keys.version.rawValue) ?? bundle.valueNotFound
    }

    var subscriptionKey: String {
        return customSubscriptionKey ?? bundle.value(for: keys.subscriptionKey.rawValue) ?? bundle.valueNotFound
    }

    var baseUrl: URL? {
        guard let endpointUrlString = (self.customUrl ?? bundle.value(for: keys.endpoint.rawValue)) else {
            Logger.e("Ensure RMAAPIEndpoint value in plist is valid")
            return nil
        }
        return URL(string: "\(endpointUrlString)")
    }
}
