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

    func getContacts(completionHandler: @escaping (Result<[MAContact]?, MASDKError>) -> Void) {
        if let userProfile = getProfileSettings(), let contactsList = userProfile.contactList {
            return completionHandler(.success(contactsList))
        }
        completionHandler(.failure(.unknownError(domain: "Unknown Error", code: 1, description: "Failed to retrieve contacts list")))
    }

    func getAccessToken(miniAppId: String,
                        scopes: MASDKAccessTokenScopes,
                        completionHandler: @escaping (Result<MATokenInfo, MASDKAccessTokenError>) -> Void) {
        if let errorMode = QASettingsTableViewController.accessTokenErrorType() {
            let message = QASettingsTableViewController.accessTokenErrorMessage()
            switch errorMode {
            case .AUTHORIZATION:
                return completionHandler(.failure(.authorizationFailureError(description: "authorizationFailureError" + ( (message != nil) ? ": " + message! : "" ))))
            default:
                return completionHandler(.failure(.error(description: "Other error" + ( (message != nil) ? ": " + message! : "" ))))
            }
        }
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
