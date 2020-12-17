import MiniApp

extension ViewController {

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

    func getAccessToken(miniAppId: String, completionHandler: @escaping (Result<MATokenInfo, MASDKCustomPermissionError>) -> Void) {
        guard let tokenInfo = getTokenInfo() else {
            completionHandler(.failure(.unknownError))
            return
        }
        completionHandler(.success(.init(accessToken: tokenInfo.tokenString, expirationDate: tokenInfo.expiryDate)))
    }
}
