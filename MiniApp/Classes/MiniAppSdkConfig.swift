import Foundation

public class MiniAppSdkConfig {
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

    public init(baseUrl: String? = nil,
                rasAppId: String? = nil,
                subscriptionKey: String? = nil,
                hostAppVersion: String? = nil) {
        self.baseUrl = baseUrl?.count ?? 0 > 0 ? baseUrl : nil
        self.rasAppId = rasAppId?.count ?? 0 > 0 ? rasAppId : nil
        self.subscriptionKey = subscriptionKey?.count ?? 0 > 0 ? subscriptionKey : nil
        self.hostAppVersion = hostAppVersion?.count ?? 0 > 0 ? hostAppVersion : nil
    }
}
