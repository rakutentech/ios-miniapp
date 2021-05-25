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
    func getContacts(completionHandler: @escaping (Result<[MAContact]?, MASDKError>) -> Void)

    @available(*, deprecated, renamed:"getContacts(completionHandler:)")
    func getContacts() -> [MAContact]?

    /// Interface that is used to retrieve the Token Info
    func getAccessToken(miniAppId: String,
                        scopes: MASDKAccessTokenScopes,
                        completionHandler: @escaping (Result<MATokenInfo, MASDKAccessTokenError>) -> Void)

    /// Old interface that was used to retrieve the Token Info. Use of a MASDKAccessTokenScopes is now mandatory. Will be removed in v4.0+
    @available(*, deprecated, renamed:"getAccessToken(miniAppId:scopes:completionHandler:)")
    func getAccessToken(miniAppId: String, completionHandler: @escaping (Result<MATokenInfo, MASDKCustomPermissionError>) -> Void)
}

public extension MiniAppUserInfoDelegate {

    func getUserName(completionHandler: @escaping (Result<String?, MASDKError>) -> Void) {
        completionHandler(.failure(.unknownError(domain: MASDKLocale.localize(.hostAppError), code: 1, description: MASDKLocale.localize(.failedToConformToProtocol))))
    }

    func getProfilePhoto(completionHandler: @escaping (Result<String?, MASDKError>) -> Void) {
        completionHandler(.failure(.unknownError(domain: MASDKLocale.localize(.hostAppError), code: 1, description: MASDKLocale.localize(.failedToConformToProtocol))))
    }

    func getContacts(completionHandler: @escaping (Result<[MAContact]?, MASDKError>) -> Void) {
        completionHandler(.failure(.unknownError(domain: MASDKLocale.localize(.hostAppError), code: 1, description: MASDKLocale.localize(.failedToConformToProtocol))))
    }

    func getContacts() -> [MAContact]? {
        let semaphore = DispatchSemaphore(value: 0)
        var contacts: [MAContact]?
        getContacts { result in
            switch result {
            case .success(let listContacts):
                contacts = listContacts
            default:
                contacts = nil
            }
            semaphore.signal()
        }
        semaphore.wait()
        return contacts
    }

    func getAccessToken(miniAppId: String,
                        scopes: MASDKAccessTokenScopes,
                        completionHandler: @escaping (Result<MATokenInfo, MASDKAccessTokenError>) -> Void) {
        completionHandler(.failure(.failedToConformToProtocol))
    }

    /// Old interface that was used to retrieve the Token Info. Use of a MASDKAccessTokenScopes is now mandatory. Will be removed in v4.0+
    func getAccessToken(miniAppId: String, completionHandler: @escaping (Result<MATokenInfo, MASDKCustomPermissionError>) -> Void) {
        completionHandler(.failure(.failedToConformToProtocol))
    }
}

public class MATokenInfo: Codable {
    let token: String
    let validUntil: Int
    let scopes: MASDKAccessTokenScopes

    public init(accessToken: String, expirationDate: Date, scopes: MASDKAccessTokenScopes?) {
        self.token = accessToken
        self.validUntil = expirationDate.dateToNumber()
        self.scopes = scopes ?? MASDKAccessTokenScopes(audience: "UNDEFINED", scopes: [])!
    }
}

/// Contact Object of a User
public class MAContact: Codable, Equatable, Hashable {
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

    public static func == (lhs: MAContact, rhs: MAContact) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(email)
    }
}

extension Date {
    func dateToNumber() -> Int {
        let timeSince1970 = self.timeIntervalSince1970
        return Int(timeSince1970 * 1000)
    }
}
