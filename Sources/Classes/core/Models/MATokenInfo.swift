import Foundation

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
