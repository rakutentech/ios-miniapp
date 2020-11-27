import Foundation

/// MiniAppSdkConfig class helps you to configure the endpoints at runtime.
public class MiniAppSdkConfig {
    @available(*, deprecated, renamed: "isPreviewMode")
    var isTestMode: Bool? {
        get {
            isPreviewMode
        }
        set {
            isPreviewMode = newValue
        }
    }

    var isPreviewMode: Bool?

    var baseUrl: String? {
        didSet {
            if baseUrl?.count ?? 0 == 0 {
                baseUrl = nil
            }
        }
    }
    @available(*, deprecated, renamed: "rasProjectId")
    var rasAppId: String? {
        didSet {
            if rasAppId?.count ?? 0 == 0 {
                rasAppId = nil
            }
        }
    }
    var rasProjectId: String? {
        didSet {
            if rasProjectId?.count ?? 0 == 0 {
                rasProjectId = nil
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
    ///   - rasProjectId: The Rakuten Studio Host App Project ID
    ///   - subscriptionKey: The Rakuten Studio Subscription Key
    ///   - hostAppVersion: The Rakuten Studio Host App version
    ///   - isPreviewMode: A boolean used by MiniApp SDK to determine which endpoint to use. Default is true
    public init(baseUrl: String? = nil,
                rasProjectId: String? = nil,
                subscriptionKey: String? = nil,
                hostAppVersion: String? = nil,
                isPreviewMode: Bool? = true) {
        self.isPreviewMode = isPreviewMode ?? true
        self.baseUrl = baseUrl?.count ?? 0 > 0 ? baseUrl : nil
        self.rasProjectId = rasProjectId?.count ?? 0 > 0 ? rasProjectId  : nil
        self.subscriptionKey = subscriptionKey?.count ?? 0 > 0 ? subscriptionKey : nil
        self.hostAppVersion = hostAppVersion?.count ?? 0 > 0 ? hostAppVersion : nil
    }

    /// Initialize a MiniAppSdkConfig object that can be used to configure a MiniApp client. All the parameters are optional.
    /// If a parameter is omitted the client will fallback its value to the configuration values provided into the project configuration .plist
    ///
    /// - Parameters:
    ///   - baseUrl: The production URL of the API endpoint
    ///   - rasAppId: The Rakuten Studio Host App ID
    ///   - subscriptionKey: The Rakuten Studio Subscription Key
    ///   - hostAppVersion: The Rakuten Studio Host App version
    ///   - isTestMode: A boolean used by MiniApp SDK to determine which endpoint to use. Default is false
    @available(*, deprecated, message: "use constructor with rasProjectId indeed. isTestMode has been renamed isPreviewMode",
    renamed: "init(baseUrl:rasProjectId:subscriptionKey:hostAppVersion:isPreviewMode:)")
    convenience public init(baseUrl: String? = nil,
                            rasAppId: String? = nil,
                            subscriptionKey: String? = nil,
                            hostAppVersion: String? = nil,
                            isTestMode: Bool? = false) {
        self.init(baseUrl: baseUrl, rasProjectId: nil, subscriptionKey: subscriptionKey, hostAppVersion: hostAppVersion, isPreviewMode: isTestMode)
        self.rasAppId = rasAppId?.count ?? 0 > 0 ? rasAppId : nil
    }
}
