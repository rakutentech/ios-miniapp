import UIKit

struct UserProfileModel: Codable {
    var displayName: String?
    var profileImageURI: String?
    var contactList: [String]?

    init(displayName: String, profileImageURI: String?, contactList: [String]?) {
        self.displayName = displayName
        self.profileImageURI = profileImageURI
        self.contactList = contactList
    }
}

func setProfileSettings(forKey key: String = "UserProfileDetail", userDisplayName: String?, profileImageURI: String?, contactList: [String] = getContactList()) -> Bool {
    if let data = try? PropertyListEncoder().encode(UserProfileModel(displayName: userDisplayName ?? "", profileImageURI: profileImageURI, contactList: contactList)) {
        UserDefaults.standard.set(data, forKey: key)
        UserDefaults.standard.synchronize()
        return true
    }
    return false
}

func getProfileSettings(key: String = "UserProfileDetail") -> UserProfileModel? {
    if let userProfile = UserDefaults.standard.data(forKey: key) {
        let userProfileData = try? PropertyListDecoder().decode(UserProfileModel.self, from: userProfile)
        return userProfileData
    }
    return nil
}

func getContactList(key: String = "UserProfileDetail") -> [String] {
    if let userProfile = UserDefaults.standard.data(forKey: key) {
           let userProfileData = try? PropertyListDecoder().decode(UserProfileModel.self, from: userProfile)
        return userProfileData?.contactList ?? []
    }
    return []
}

func updateContactList(list: [String]?) {
    if let profileDetail = getProfileSettings() {
        _ = setProfileSettings(userDisplayName: profileDetail.displayName, profileImageURI: profileDetail.profileImageURI, contactList: list ?? [])
    } else {
        _ = setProfileSettings(userDisplayName: "", profileImageURI: "", contactList: list ?? [])
    }
}
