import Foundation

/**
 Public Protocol that will be used by the Mini App to communicate
 with the Native implementation for User profile related retrieval
*/
public protocol MiniAppUserInfoDelegate: AnyObject {

    /// Interface that is used to retrieve the user name from the User Profile
    func getUserName(completionHandler: @escaping (Result<String?, MASDKError>) -> Void)

    /// Interface that is used to retrieve the Image URI
    func getProfilePhoto(completionHandler: @escaping (Result<String?, MASDKError>) -> Void)

    /// Interface that is used to retrieve the Contact list
    func getContacts(completionHandler: @escaping (Result<[MAContact]?, MASDKError>) -> Void)

    /// Interface that is used to retrieve the Token Info
    func getAccessToken(miniAppId: String,
                        scopes: MASDKAccessTokenScopes,
                        completionHandler: @escaping (Result<MATokenInfo, MASDKAccessTokenError>) -> Void)

    /// Interface that is used to retrieve rakuten points
    func getPoints(completionHandler: @escaping (Result<MAPoints, MASDKPointError>) -> Void)
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

    /// Method to support old version of getContacts() interface
    /// - Returns: List of MAContact
    func getContacts() -> [MAContact]? {
        let semaphore = DispatchSemaphore(value: 0)
        var contacts: [MAContact]?
        getContacts { result in
            if case .success(let listContacts) = result {
                contacts = listContacts
            } else {
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

    func getPoints(completionHandler: @escaping (Result<MAPoints, MASDKPointError>) -> Void) {
        completionHandler(.failure(.failedToConformToProtocol))
    }
}

/// Contact Object of a User
public struct MAContact: Codable, Equatable, Hashable, Identifiable {
    /// Contact ID
    public var id: String
    /// Contact Name
    public var name: String?
    /// Contact Email address
    public var email: String?
    /// Contact Email addresses list
    public var allEmailList: [String]?

    public init(id: String, name: String? = nil, email: String? = nil, allEmailList: [String]? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.allEmailList = allEmailList
    }

    public static func == (lhs: MAContact, rhs: MAContact) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(email)
        hasher.combine(allEmailList)
    }
}
