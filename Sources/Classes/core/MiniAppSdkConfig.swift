import Foundation

/// Struct used to configure SSL Pinning
public struct MiniAppConfigSSLKeyHash {
    enum KeyType: String {
        case main, backup
    }
    /// SSL Pin
    public var pin: String
    /// Default SSL pin that is used as a fallback
    public var backupPin: String?

    /// Constructor for MiniAppConfigSSLKeyHash
    /// - Parameters:
    ///   - pin: SSL Pin string
    ///   - backup: Default SSL Pin string (Optional)
    public init(pin: String, backup: String? = nil) {
        if pin == backup {
            preconditionFailure("Pin can't be equal to its backup value")
        }
        self.pin = pin
        backupPin = backup
    }
    func matches(_ keys: String...) -> KeyType? {
        matches(keys)
    }
    func matches(_ keys: [String]) -> KeyType? {
        if keys.contains(pin) {
            return .main
        } else if let key = backupPin, keys.contains(key) {
            return .backup
        }
        return nil
    }
}
/// MiniAppSdkConfig class helps you to configure the endpoints at runtime.
public class MiniAppSdkConfig {

    /// Preview mode (Mini app won't be stored in local)
    public var isPreviewMode: Bool?
    /// Bool used to verifty Mini app signature after download is complete
    public var requireMiniAppSignatureVerification: Bool?

    /// Base Endpoint URL
    public var baseUrl: String? {
        didSet {
            if baseUrl?.count ?? 0 == 0 {
                baseUrl = nil
            }
        }
    }
    /// Host/Domain name which is retrieved from Base URL
    public var host: String? {
        if let url = baseUrl {
            return URLComponents(string: url)?.host
        }
        return nil
    }
    /// MiniAppConfigSSLKeyHash config object
    public var sslKeyHash: MiniAppConfigSSLKeyHash? {
        didSet {
            if sslKeyHash?.pin.count ?? 0 == 0 {
                sslKeyHash = nil
            }
        }
    }
    /// Project ID that is associated with the mini app
    public var rasProjectId: String? {
        didSet {
            if rasProjectId?.count ?? 0 == 0 {
                rasProjectId = nil
            }
        }
    }
    /// Subscription Key that is associated with the mini app
    public var subscriptionKey: String? {
        didSet {
            if subscriptionKey?.count ?? 0 == 0 {
                subscriptionKey = nil
            }
        }
    }
    /// Optional - Host app version for e.g, 1.0
    public var hostAppVersion: String? {
        didSet {
            if hostAppVersion?.count ?? 0 == 0 {
                hostAppVersion = nil
            }
        }
    }

    /// Array of MAAnalyticsConfig that is used to send impressions
    public var analyticsConfigList: [MAAnalyticsConfig]? {
        didSet {
            if analyticsConfigList?.count == 0 {
                analyticsConfigList = []
            }
        }
    }

    /// Initialize a MiniAppSdkConfig object that can be used to configure a MiniApp client. All the parameters are optional.
    /// If a parameter is omitted the client will fallback its value to the configuration values provided into the project configuration .plist
    ///
    /// - Parameters:
    ///   - baseUrl: The production URL of the API endpoint
    ///   - rasProjectId: The Rakuten Studio Host App Project ID
    ///   - subscriptionKey: The Rakuten Studio Subscription Key
    ///   - hostAppVersion: The Rakuten Studio Host App version
    ///   - isPreviewMode: A boolean used by MiniApp SDK to determine which endpoint to use. Default is true
    ///   - requireMiniAppSignatureVerification: A boolean used by MiniApp SDK to determine if you prevent man in the middle attack during MiniApp launch. Default is false
    ///   - sslKeyHash: A SSL pin and backup pin used for SSL pinning
    public init(baseUrl: String? = nil,
                rasProjectId: String? = nil,
                subscriptionKey: String? = nil,
                hostAppVersion: String? = nil,
                isPreviewMode: Bool? = nil,
                analyticsConfigList: [MAAnalyticsConfig]? = [],
                requireMiniAppSignatureVerification: Bool? = nil,
                sslKeyHash: MiniAppConfigSSLKeyHash? = nil) {
        self.isPreviewMode = isPreviewMode
        self.baseUrl = baseUrl?.count ?? 0 > 0 ? baseUrl : nil
        self.rasProjectId = rasProjectId?.count ?? 0 > 0 ? rasProjectId  : nil
        self.subscriptionKey = subscriptionKey?.count ?? 0 > 0 ? subscriptionKey : nil
        self.hostAppVersion = hostAppVersion?.count ?? 0 > 0 ? hostAppVersion : nil
        self.analyticsConfigList = analyticsConfigList
        self.requireMiniAppSignatureVerification = requireMiniAppSignatureVerification
        self.sslKeyHash = sslKeyHash
    }
}
