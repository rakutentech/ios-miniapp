/**
 Public Protocol that will be used by the Mini App to get Authentication
 info, such as Access token
*/
public protocol MiniAppAuthenticationDelegate: class {
    /// Interface that is used to retrieve the Token Info
    func getAccessToken(completionHandler: @escaping (Result<MATokenInfo, MASDKCustomPermissionError>) -> Void)
}

public extension MiniAppAuthenticationDelegate {
    func getAccessToken(completionHandler: @escaping (Result<MATokenInfo, MASDKCustomPermissionError>) -> Void) {
        completionHandler(.failure(.failedToConformToProtocol))
    }
}

public class MATokenInfo: Codable {
    let token: String
    let validUntil: Date

    public init(accessToken: String, expirationDate: Date) {
        self.token = accessToken
        self.validUntil = expirationDate
    }
}
