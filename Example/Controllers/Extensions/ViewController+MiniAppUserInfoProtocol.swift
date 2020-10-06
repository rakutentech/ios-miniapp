import MiniApp

extension ViewController: MiniAppUserInfoProtocol {

    func getUserName() -> String {
        guard let userProfile = getProfileSettings() else {
            return ""
        }
        guard let userName = userProfile.displayName else {
            return ""
        }
        return userName
    }

    func getProfilePhoto() -> String {
        guard let userProfile = getProfileSettings() else {
            return ""
        }
        guard let userProfilePhoto = userProfile.profileImageURI else {
            return ""
        }
        return userProfilePhoto
    }
}
