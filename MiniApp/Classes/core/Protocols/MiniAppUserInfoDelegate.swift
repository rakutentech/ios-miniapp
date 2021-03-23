/**
 Public Protocol that will be used by the Mini App to communicate
 with the Native implementation for User profile related retrieval
*/
public protocol MiniAppUserInfoDelegate: class {

    /// Interface that is used to retrieve the user name from the User Profile
    func getUserName(completionHandler: @escaping (Result<String?, MASDKError>) -> Void)

    /// Interface that is used to retrieve the Image URI
    func getProfilePhoto(completionHandler: @escaping (Result<String?, MASDKError>) -> Void)

    /// Interface that is used to retrieve the Contact list
    func getContacts() -> [MAContact]?

    /// Interface that is used to retrieve the Token Info
    func getAccessToken(miniAppId: String,
                        scopes: MASDKAccessTokenScopes?,
                        completionHandler: @escaping (Result<MATokenInfo, MASDKCustomPermissionError>) -> Void)
}

public extension MiniAppUserInfoDelegate {

    func getUserName(completionHandler: @escaping (Result<String?, MASDKError>) -> Void) {
        completionHandler(.failure(.unknownError(domain: NSLocalizedString("host_app_error", comment: ""), code: 1, description: NSLocalizedString("failed_to_conform_to_protocol", comment: ""))))
    }

    func getProfilePhoto(completionHandler: @escaping (Result<String?, MASDKError>) -> Void) {
        completionHandler(.failure(.unknownError(domain: NSLocalizedString("host_app_error", comment: ""), code: 1, description: NSLocalizedString("failed_to_conform_to_protocol", comment: ""))))
    }

    func getContacts() -> [MAContact]? {
        return nil
    }

    func getAccessToken(miniAppId: String, scopes: MASDKAccessTokenScopes?, completionHandler: @escaping (Result<MATokenInfo, MASDKCustomPermissionError>) -> Void) {
        completionHandler(.failure(.failedToConformToProtocol))
    }
}

public class MATokenInfo: Codable {
    let token: String
    let validUntil: Int
    let audience: String?
    let scopes: [String]?

    public init(accessToken: String, expirationDate: Date, scopes: MASDKAccessTokenScopes?) {
        self.token = accessToken
        self.validUntil = expirationDate.dateToNumber()
        self.audience = scopes?.audience
        self.scopes = scopes?.scopes
    }
}

/// Contact Object of a User
public class MAContact: Codable {
    /// Contact ID
    public let id: String
    /// Contact Name
    public let name: String?
    /// Contact Email address
    public let email: String?

    public init(id: String, name: String? = nil, email: String? = nil) {
        self.id = id
        self.name = name
        self.email = email
    }
}

extension Date {
    func dateToNumber() -> Int {
        let timeSince1970 = self.timeIntervalSince1970
        return Int(timeSince1970 * 1000)
    }
}
