internal protocol EnvironmentProtocol {
    var valueNotFound: String { get }
    func value(for key: String) -> String?
}

internal class Environment {
    let bundle: EnvironmentProtocol

    var customUrl: String?
    var customAppId: String?
    var customAppVersion: String?
    var customSubscriptionKey: String?

    init(bundle: EnvironmentProtocol = Bundle.main) {
        self.bundle = bundle
    }

    var appId: String {
        return customAppId ?? bundle.value(for: "RASApplicationIdentifier" as String) ?? bundle.valueNotFound
    }

    var appVersion: String {
        return customAppVersion ?? bundle.value(for: "CFBundleShortVersionString" as String) ?? bundle.valueNotFound
    }

    var subscriptionKey: String {
        return customSubscriptionKey ?? bundle.value(for: "RASProjectSubscriptionKey") ?? bundle.valueNotFound
    }

    var baseUrl: URL? {
        guard let endpointUrlString = (self.customUrl ?? bundle.value(for: "RMAAPIEndpoint")) else {
            Logger.e("Ensure RMAAPIEndpoint value in plist is valid")
            return nil
        }
        return URL(string: "\(endpointUrlString)")
    }
}
