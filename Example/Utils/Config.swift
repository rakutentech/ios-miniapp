import UIKit
import MiniApp

class Config: NSObject {
    enum Key: String {
        case applicationIdentifier               = "RASApplicationIdentifier",
             projectId                           = "RASProjectId",
             version                             = "CFBundleShortVersionString",
             subscriptionKey                     = "RASProjectSubscriptionKey",
             endpoint                            = "RMAAPIEndpoint",
             stagingProjectId                    = "RASStagingProjectId",
             stagingSubscriptionKey              = "RASStagingProjectSubscriptionKey",
             stagingEndpoint                     = "RMAAPIStagingEndpoint",
             isPreviewMode                       = "RMAIsPreviewMode",
             requireMiniAppSignatureVerification = "RMARequireMiniAppSignatureVerification",
             sslKeyHash                          = "RMASSLKeyHash"
    }
    
    enum LocalKey: String {
        case maxSecureStorageFileLimit = "MAMaxSecureStorageFileLimit"
    }

    private enum InternalKey: String {
        case stagingActive = "MiniApp.Settings.StagingEnvironmentActive"
    }

    static var isProd: Bool {
        !UserDefaults.standard.bool(forKey: InternalKey.stagingActive.rawValue)
    }

    static var userDefaults: UserDefaults? {
        return getUserDefaults(isProd: isProd)
    }

    // swiftlint:disable:next todo
    // TODO: Make it as CI Configurable
    class func current(
        rasProjectId: String? = Config.getUserDefaultsString(key: .projectId),
        subscriptionKey: String? = Config.getUserDefaultsString(key: .subscriptionKey),
        pinningEnabled: Bool = false
    ) -> MiniAppSdkConfig {
        var pinConf: MiniAppConfigSSLKeyHash?
        if pinningEnabled, let keyHash = (Bundle.main.object(forInfoDictionaryKey: "RMASSLKeyHash") as? [String: Any?])?["main"] as? String {
            pinConf = MiniAppConfigSSLKeyHash(pin: keyHash, backup: (Bundle.main.object(forInfoDictionaryKey: "RMASSLKeyHash") as? [String: Any?])?["backup"] as? String)
        }
        let storageMaxSizeInBytes = UserDefaults.standard.integer(forKey: LocalKey.maxSecureStorageFileLimit.rawValue)
        return MiniAppSdkConfig(
            baseUrl: getUserDefaultsString(key: .endpoint),
            rasProjectId: rasProjectId,
            subscriptionKey: subscriptionKey,
            hostAppVersion: Config.userDefaults?.string(forKey: Config.Key.version.rawValue),
            isPreviewMode: Config.userDefaults?.value(forKey: Config.Key.isPreviewMode.rawValue) as? Bool,
            analyticsConfigList: [MAAnalyticsConfig(acc: "477", aid: "998")],
            requireMiniAppSignatureVerification: Config.userDefaults?.value(forKey: Config.Key.requireMiniAppSignatureVerification.rawValue) as? Bool,
            sslKeyHash: pinConf,
            storageMaxSizeInBytes: storageMaxSizeInBytes > 0 ? UInt64(storageMaxSizeInBytes) : nil
        )
    }

    /// Returns a `MiniAppNavigationConfig` with default values
    /// See `DisplayController` class on how to communicate navigation events to `MiniAppView`
    class func getNavConfig(delegate: MiniAppNavigationDelegate) -> MiniAppNavigationConfig {
        return MiniAppNavigationConfig(navigationBarVisibility: .never, navigationDelegate: delegate, customNavigationView: nil)
    }

    class func changeEnvironment(isStaging: Bool) {
        UserDefaults.standard.set(isStaging, forKey: InternalKey.stagingActive.rawValue)
        UserDefaults.standard.synchronize()
    }

    class func getInfoPlistString(key: Key) -> String? {
        switch key {
        default:
            return Bundle.main.infoDictionary?[key.rawValue] as? String
        }
    }

    class func getUserDefaultsString(key: Key) -> String? {
        switch key {
        case .stagingProjectId:
            return userDefaults?.string(forKey: Key.projectId.rawValue)
        case .stagingSubscriptionKey:
            return userDefaults?.string(forKey: Key.subscriptionKey.rawValue)
        default:
            return userDefaults?.string(forKey: key.rawValue)
        }
    }

    class func setUserDefaultsString(key: Key, value: String?) {
        guard let value = value else {
            userDefaults?.set(nil, forKey: key.rawValue)
            return
        }
        switch key {
        case .stagingEndpoint:
            userDefaults?.set(value, forKey: Key.endpoint.rawValue)
        case .stagingProjectId:
            userDefaults?.set(value, forKey: Key.projectId.rawValue)
        case .stagingSubscriptionKey:
            userDefaults?.set(value, forKey: Key.subscriptionKey.rawValue)
        default:
            userDefaults?.set(value, forKey: key.rawValue)
        }
        userDefaults?.synchronize()
    }

    class func getUserDefaults(isProd: Bool) -> UserDefaults? {
        let suiteName = isProd ?
            "com.rakuten.tech.mobile.miniapp.MiniAppDemo.settings.prod" :
            "com.rakuten.tech.mobile.miniapp.MiniAppDemo.settings.stg"
        return UserDefaults(suiteName: suiteName)
    }

    class func savePlistValueToUserDefaults(for key: Key) {
        switch key {
        case .endpoint:
            let url = Bundle.main.infoDictionary?[key.rawValue] as? String
            let userDefaults = getUserDefaults(isProd: true)
            userDefaults?.set(url, forKey: Key.endpoint.rawValue)
            userDefaults?.synchronize()
        case .stagingEndpoint:
            let url = Bundle.main.infoDictionary?[key.rawValue] as? String
            let userDefaults = getUserDefaults(isProd: false)
            userDefaults?.set(url, forKey: Key.endpoint.rawValue)
            userDefaults?.synchronize()
        default:
            ()
        }
    }
}
