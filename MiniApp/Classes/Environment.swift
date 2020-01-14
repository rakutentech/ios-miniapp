internal protocol EnvironmentProtocol {
    var valueNotFound: String { get }
    func value(for key: String) -> String?
}

internal class Environment {
    let bundle: EnvironmentProtocol

    init(bundle: EnvironmentProtocol = Bundle.main) {
        self.bundle = bundle
    }

    var appId: String {
        return bundle.value(for: "RASApplicationIdentifier" as String) ?? bundle.valueNotFound
    }

    var appVersion: String {
        return bundle.value(for: "CFBundleShortVersionString" as String) ?? bundle.valueNotFound
    }

    var subscriptionKey: String {
        return bundle.value(for: "RASProjectSubscriptionKey") ?? bundle.valueNotFound
    }

    var baseUrl: URL? {
        guard let endpointUrlString = bundle.value(for: "RMAConfigAPIEndpoint") else {
            Logger.e("Ensure RMAConfigAPIEndpoint value in plist is valid")
            return nil
        }
        return URL(string: "\(endpointUrlString)")
    }

    var listingUrl: URL? {
        return baseUrl?.appendingPathComponent("/oneapp/ios/\(appVersion)/miniapps")
    }

    func manifestRequestUrl(with miniAppId: String, versionId: String) -> URL? {
        return baseUrl?.appendingPathComponent("/miniapp/\(miniAppId)/version/\(versionId)/manifest")
    }
}
