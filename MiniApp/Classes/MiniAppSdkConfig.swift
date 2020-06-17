import Foundation

public class MiniAppSdkConfig {
    var url: String? {
        if loadTestVersions ?? false {
            return self.testBaseUrl
        } else {
            return self.baseUrl
        }
    }

    var loadTestVersions: Bool?

    private var baseUrl: String? {
        didSet {
            if baseUrl?.count ?? 0 == 0 {
                baseUrl = nil
            }
        }
    }
    private var testBaseUrl: String? {
        didSet {
            if testBaseUrl?.count ?? 0 == 0 {
                testBaseUrl = nil
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
                testBaseUrl: String? = nil,
                loadTestVersions: Bool? = false,
                rasAppId: String? = nil,
                subscriptionKey: String? = nil,
                hostAppVersion: String? = nil) {
        self.loadTestVersions = loadTestVersions
        self.baseUrl = baseUrl?.count ?? 0 > 0 ? baseUrl : nil
        self.testBaseUrl = testBaseUrl?.count ?? 0 > 0 ? testBaseUrl : nil
        self.rasAppId = rasAppId?.count ?? 0 > 0 ? rasAppId : nil
        self.subscriptionKey = subscriptionKey?.count ?? 0 > 0 ? subscriptionKey : nil
        self.hostAppVersion = hostAppVersion?.count ?? 0 > 0 ? hostAppVersion : nil
    }
}
