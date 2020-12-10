/**
 Public Protocol that will be used by the Mini App to communicate
 with the Native implementation for User profile related retrieval
*/
public protocol MiniAppUserInfoDelegate: class {
    /// Interface that is used to retrieve the user name from the User Profile
    func getUserName() -> String?

    /// Interface that is used to retrieve the Image URI
    func getProfilePhoto() -> String?
    
    /// Interface that is used to retrieve the Contact list
    func getContacts() -> [MAContact]?

    /// Interface that is used to retrieve the Token Info
    func getAccessToken(miniAppId: String, completionHandler: @escaping (Result<MATokenInfo, MASDKCustomPermissionError>) -> Void)
}

public extension MiniAppUserInfoDelegate {
    func getUserName() -> String? {
        return nil
    }

    func getProfilePhoto() -> String? {
        return nil
    }
    
    func getContacts() -> [MAContact]? {
        return nil
    }

    func getAccessToken(miniAppId: String, completionHandler: @escaping (Result<MATokenInfo, MASDKCustomPermissionError>) -> Void) {
        completionHandler(.failure(.failedToConformToProtocol))
    }
}

public class MATokenInfo: Codable {
    let token: String
    let validUntil: Int

    public init(accessToken: String, expirationDate: Date) {
        self.token = accessToken
        self.validUntil = expirationDate.dateToNumber()
    }
}

public class MAContact: Codable {
    let id: String
    
    public init(id: String) {
        self.id = id
    }
}

extension Date {
    func dateToNumber() -> Int {
        let timeSince1970 = self.timeIntervalSince1970
        return Int(timeSince1970 * 1000)
    }
}
