import UIKit
import MiniApp

class Config: NSObject {
    enum Key: String {
        case applicationIdentifier = "RASApplicationIdentifier",
        projectId = "RASProjectId",
        version = "CFBundleShortVersionString",
        subscriptionKey = "RASProjectSubscriptionKey",
        endpoint = "RMAAPIEndpoint",
        isPreviewMode = "RMAIsPreviewMode"
    }

    static let userDefaults = UserDefaults(suiteName: "com.rakuten.tech.mobile.miniapp.MiniAppDemo.settings")

    // swiftlint:disable:next todo
    // TODO: Make it as CI Configurable
    class func current() -> MiniAppSdkConfig {
        MiniAppSdkConfig(baseUrl: Config.userDefaults?.string(forKey: Config.Key.endpoint.rawValue),
            rasProjectId: Config.userDefaults?.string(forKey: Config.Key.projectId.rawValue),
            subscriptionKey: Config.userDefaults?.string(forKey: Config.Key.subscriptionKey.rawValue),
            hostAppVersion: Config.userDefaults?.string(forKey: Config.Key.version.rawValue),
            isPreviewMode: Config.userDefaults?.bool(forKey: Config.Key.isPreviewMode.rawValue),
            analyticsConfigList: [MAAnalyticsConfig(acc: "477", aid: "998")])
    }

    /// Returns a `MiniAppNavigationConfig` with default values
    /// See `DisplayController` class on how to communicate navigation events to `MiniAppView`
    class func getNavConfig(delegate: MiniAppNavigationDelegate) -> MiniAppNavigationConfig {
        return MiniAppNavigationConfig(navigationBarVisibility: .never, navigationDelegate: delegate, customNavigationView: nil)
    }
}
