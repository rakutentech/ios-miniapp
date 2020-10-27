/**
 Public Protocol that will be used by the Mini App to get Authentication
 info, such as Access token
*/
public protocol MiniAppAuthenticationDelegate: class {
    /// Interface that is used to retrieve the Token Info
    func getAccessToken() -> MATokenInfo?
}

public extension MiniAppAuthenticationDelegate {
    func getAccessToken() -> MATokenInfo? {
        return MATokenInfo(accessToken: "", expirationDate: "")
    }
}

public struct MATokenInfo: Codable {
    let accessToken: String
    let expirationDate: String
}
