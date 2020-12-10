import MiniApp

extension ViewController {

    func getUserName() -> String? {
        guard let userProfile = getProfileSettings(), let userName = userProfile.displayName else {
            return nil
        }
        return userName
    }

    func getProfilePhoto() -> String? {
        guard let userProfile = getProfileSettings(), let userProfilePhoto = userProfile.profileImageURI else {
            return nil
        }
        return userProfilePhoto
    }

    func getContacts() -> [MAContact]? {
        guard let userProfile = getProfileSettings(), let contactList = userProfile.contactList else {
            return nil
        }
        let contacts = contactList.map { MAContact(id: $0.id) }
        return contacts
    }

    func getAccessToken(miniAppId: String, completionHandler: @escaping (Result<MATokenInfo, MASDKCustomPermissionError>) -> Void) {
        guard let tokenInfo = getTokenInfo() else {
            completionHandler(.failure(.unknownError))
            return
        }
        completionHandler(.success(.init(accessToken: tokenInfo.tokenString, expirationDate: tokenInfo.expiryDate)))
    }
}
