import UIKit
import MiniApp

class Config: NSObject {
    enum Key: String {
        case applicationIdentifier = "RASApplicationIdentifier",
        version = "CFBundleShortVersionString",
        subscriptionKey = "RASProjectSubscriptionKey",
        endpoint = "RMAAPIEndpoint",
        testEndpoint  = "RMAAPITestEndpoint",
        loadTestVersions = "LoadTestVersions"
    }

    static let userDefaults = UserDefaults(suiteName: "com.rakuten.tech.mobile.miniapp.MiniAppDemo.settings")

    class func getCurrent() -> MiniAppSdkConfig {
        return MiniAppSdkConfig(baseUrl: Config.userDefaults?.string(forKey: Config.Key.endpoint.rawValue),
                                testBaseUrl: Config.userDefaults?.string(forKey: Config.Key.testEndpoint.rawValue),
                                loadTestVersions: Config.userDefaults?.bool(forKey: Config.Key.loadTestVersions.rawValue),
                                rasAppId: Config.userDefaults?.string(forKey: Config.Key.applicationIdentifier.rawValue),
                                subscriptionKey: Config.userDefaults?.string(forKey: Config.Key.subscriptionKey.rawValue),
                                hostAppVersion: Config.userDefaults?.string(forKey: Config.Key.version.rawValue))
    }
}
