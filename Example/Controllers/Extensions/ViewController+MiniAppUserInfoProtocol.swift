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

    func getAccessToken(completionHandler: @escaping (Result<MATokenInfo, MASDKCustomPermissionError>) -> Void) {
        completionHandler(.success(.init(accessToken: "ACCESS_TOKEN", expirationDate: Date())))
    }
}
