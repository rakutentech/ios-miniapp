import MiniApp

extension ViewController: MiniAppUserInfoDelegate {

    func getUserName(completionHandler: @escaping (Result<String?, MASDKError>) -> Void) {
        guard let userProfile = getProfileSettings(), let userName = userProfile.displayName else {
            return completionHandler(.failure(.unknownError(domain: "Unknown Error", code: 1, description: "Failed to retrieve User name")))
        }
        completionHandler(.success(userName))
    }

    func getProfilePhoto(completionHandler: @escaping (Result<String?, MASDKError>) -> Void) {
        guard let userProfile = getProfileSettings(), let userProfilePhoto = userProfile.profileImageURI else {
            return completionHandler(.failure(.unknownError(domain: "Unknown Error", code: 1, description: "Failed to retrieve Profile photo")))
        }
        completionHandler(.success(userProfilePhoto))
    }

    func getContacts() -> [MAContact]? {
        guard let userProfile = getProfileSettings(), let contactList = userProfile.contactList else {
            return nil
        }
        return contactList
    }

    func getAccessToken(miniAppId: String,
                        scopes: MASDKAccessTokenScopes,
                        completionHandler: @escaping (Result<MATokenInfo, MASDKCustomPermissionError>) -> Void) {
        var resultToken = "ACCESS_TOKEN"
        var resultDate = Date()
        let resultScopes = scopes

        if let tokenInfo = getTokenInfo() {
           resultToken = tokenInfo.tokenString
           resultDate = tokenInfo.expiryDate
        }
        completionHandler(.success(.init(accessToken: resultToken, expirationDate: resultDate, scopes: resultScopes)))
    }
}
