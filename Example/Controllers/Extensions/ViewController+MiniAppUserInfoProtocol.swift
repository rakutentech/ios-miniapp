import MiniApp

extension ViewController: MiniAppUserInfoProtocol {

    func getUserName() -> String {
        guard let userProfile = getProfileSettings(), let userName = userProfile.displayName else {
            return ""
        }
        return userName
    }

    func getProfilePhoto() -> String {
        guard let userProfile = getProfileSettings(), let userProfilePhoto = userProfile.profileImageURI else {
            return ""
        }
        return userProfilePhoto
    }
}
