import Foundation
import TrustKit

public struct MiniAppSSLConfig {
    internal var domains: [String: [String: Any]]
    lazy private var dateFormatter: DateFormatter = DateFormatter()

    init() {
        domains = [:]
    }

    init(with domain: String, enforcePinning: Bool = true, includeSubDomains: Bool = false, expirationDate: Date? = nil, keyHashes: String...) {
        self.init()
        setDomain(name: domain, enforcePinning: enforcePinning, includeSubDomains: includeSubDomains, expirationDate: expirationDate, keyHashes: keyHashes)
    }

    mutating func setDomain(name: String, enforcePinning: Bool = true, includeSubDomains: Bool = false, expirationDate: Date? = nil, keyHashes: String...) {
        setDomain(name: name, enforcePinning: enforcePinning, expirationDate: expirationDate, keyHashes: keyHashes)
    }

    private mutating func setDomain(name: String, enforcePinning: Bool = true, includeSubDomains: Bool = false, expirationDate: Date? = nil, keyHashes: [String]) {
        var domain: [String: Any] = [:]
        if let dateString = expirationDate {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            domain[kTSKExpirationDate] = dateFormatter.string(from: dateString)
        }
        domain[kTSKEnforcePinning] = enforcePinning
        domain[kTSKIncludeSubdomains] = includeSubDomains
        domain[kTSKPublicKeyHashes] = keyHashes
        domains[name] = domain
    }

    internal func dictionary() -> [String: Any] {
        var dict: [String: Any] = [kTSKSwizzleNetworkDelegates: false]
        dict[kTSKPinnedDomains] = domains
        return dict
    }
}
