import UIKit
import MiniApp

class Config: NSObject {
    enum Key: String {
        case applicationIdentifier               = "RASApplicationIdentifier",
             projectId                           = "RASProjectId",
             version                             = "CFBundleShortVersionString",
             subscriptionKey                     = "RASProjectSubscriptionKey",
             endpoint                            = "RMAAPIEndpoint",
             isPreviewMode                       = "RMAIsPreviewMode",
             requireMiniAppSignatureVerification = "RMARequireMiniAppSignatureVerification",
             sslKeyHash                          = "RMASSLKeyHash"
    }

    static let userDefaults = UserDefaults(suiteName: "com.rakuten.tech.mobile.miniapp.MiniAppDemo.settings")

    // swiftlint:disable:next todo
    // TODO: Make it as CI Configurable
    class func current(rasProjectId: String? = Config.userDefaults?.string(forKey: Config.Key.projectId.rawValue),
                       subscriptionKey: String? = Config.userDefaults?.string(forKey: Config.Key.subscriptionKey.rawValue), pinningEnabled: Bool = false) -> MiniAppSdkConfig {
        var pinConf: MiniAppConfigSSLKeyHash?
        if pinningEnabled, let keyHash = (Bundle.main.object(forInfoDictionaryKey: "RMASSLKeyHash") as? [String: Any?])?["main"] as? String {
            pinConf = MiniAppConfigSSLKeyHash(pin: keyHash, backup: (Bundle.main.object(forInfoDictionaryKey: "RMASSLKeyHash") as? [String: Any?])?["backup"] as? String)
        }
        return MiniAppSdkConfig(
                baseUrl: Config.userDefaults?.string(forKey: Config.Key.endpoint.rawValue),
                rasProjectId: rasProjectId,
                subscriptionKey: subscriptionKey,
                hostAppVersion: Config.userDefaults?.string(forKey: Config.Key.version.rawValue),
                isPreviewMode: Config.userDefaults?.value(forKey: Config.Key.isPreviewMode.rawValue) as? Bool,
                analyticsConfigList: [MAAnalyticsConfig(acc: "477", aid: "998")],
                requireMiniAppSignatureVerification: Config.userDefaults?.value(forKey: Config.Key.requireMiniAppSignatureVerification.rawValue) as? Bool,
                sslKeyHash: pinConf
        )
    }

    /// Returns a `MiniAppNavigationConfig` with default values
    /// See `DisplayController` class on how to communicate navigation events to `MiniAppView`
    class func getNavConfig(delegate: MiniAppNavigationDelegate) -> MiniAppNavigationConfig {
        return MiniAppNavigationConfig(navigationBarVisibility: .never, navigationDelegate: delegate, customNavigationView: nil)
    }
}
