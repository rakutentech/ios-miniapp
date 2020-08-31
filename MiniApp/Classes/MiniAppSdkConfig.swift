import Foundation

/// MiniAppSdkConfig class helps you to configure the endpoints at runtime.
public class MiniAppSdkConfig {
    var isTestMode: Bool?

    var baseUrl: String? {
        didSet {
            if baseUrl?.count ?? 0 == 0 {
                baseUrl = nil
            }
        }
    }
    var rasAppId: String? {
        didSet {
            if rasAppId?.count ?? 0 == 0 {
                rasAppId = nil
            }
        }
    }
    var subscriptionKey: String? {
        didSet {
            if subscriptionKey?.count ?? 0 == 0 {
                subscriptionKey = nil
            }
        }
    }
    var hostAppVersion: String? {
        didSet {
            if hostAppVersion?.count ?? 0 == 0 {
                hostAppVersion = nil
            }
        }
    }

    /// Initialize a MiniAppSdkConfig object that can be used to configure a MiniApp client. All the parameters are optional.
    /// If a parameter is omitted the client will fallback its value to the configuration values provided into the project configuration .plist
    ///
    /// - Parameters:
    ///   - baseUrl: The production URL of the API endpoint
    ///   - testBaseUrl: The production URL of the API endpoint
    ///   - loadTestVersions: A boolean used by MiniApp SDK to determine which endpoint to use. Default is false
    ///   - rasAppId: The Rakuten Studio Host App ID
    ///   - subscriptionKey: The Rakuten Studio Subscription Key
    ///   - hostAppVersion: The Rakuten Studio Host App version

    public init(baseUrl: String? = nil,
                rasAppId: String? = nil,
                subscriptionKey: String? = nil,
                hostAppVersion: String? = nil,
                isTestMode: Bool? = false) {
        self.isTestMode = isTestMode
        self.baseUrl = baseUrl?.count ?? 0 > 0 ? baseUrl : nil
        self.rasAppId = rasAppId?.count ?? 0 > 0 ? rasAppId : nil
        self.subscriptionKey = subscriptionKey?.count ?? 0 > 0 ? subscriptionKey : nil
        self.hostAppVersion = hostAppVersion?.count ?? 0 > 0 ? hostAppVersion : nil
    }
}
