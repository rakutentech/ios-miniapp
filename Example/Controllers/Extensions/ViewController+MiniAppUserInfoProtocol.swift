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
}
