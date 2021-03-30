import UIKit
import MiniApp

struct UserProfileModel: Codable {
    var displayName: String?
    var profileImageURI: String?
    var contactList: [MAContact]?

    init(displayName: String, profileImageURI: String?, contactList: [MAContact]?) {
        self.displayName = displayName
        self.profileImageURI = profileImageURI
        self.contactList = contactList
    }
}

struct AccessTokenInfo: Codable {
    var tokenString: String
    var expiryDate: Date
    let audience: String?
    let scopes: [String]?

    init(accessToken: String, expiry: Date, scopes: MASDKAccessTokenScopes?) {
        self.tokenString = accessToken
        self.expiryDate = expiry
        self.audience = scopes?.audience
        self.scopes = scopes?.scopes
    }
}

struct QueryParamInfo: Codable {
    var queryString: String

    init(queryString: String) {
        self.queryString = queryString
    }
}

struct MiniAppLaunchInfo: Codable {
    var isLaunchedAlready: Bool

    init(isLaunchedAlready: Bool = false) {
        self.isLaunchedAlready = isLaunchedAlready
    }
}

func setProfileSettings(forKey key: String = "UserProfileDetail", userDisplayName: String?, profileImageURI: String?, contactList: [MAContact]? = getContactList()) -> Bool {
    if let data = try? PropertyListEncoder().encode(UserProfileModel(displayName: userDisplayName ?? "", profileImageURI: profileImageURI, contactList: contactList)) {
        UserDefaults.standard.set(data, forKey: key)
        return UserDefaults.standard.synchronize()
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

func getContactList(key: String = "UserProfileDetail") -> [MAContact]? {
    if let userProfile = UserDefaults.standard.data(forKey: key) {
        let userProfileData = try? PropertyListDecoder().decode(UserProfileModel.self, from: userProfile)
        return userProfileData?.contactList
    }
    return nil
}

func updateContactList(list: [MAContact]?) {
    if let profileDetail = getProfileSettings() {
        _ = setProfileSettings(userDisplayName: profileDetail.displayName, profileImageURI: profileDetail.profileImageURI, contactList: list)
    } else {
        _ = setProfileSettings(userDisplayName: "", profileImageURI: "", contactList: list)
    }
}

@discardableResult func saveTokenInfo(accessToken: String, expiryDate: Date, scopes: MASDKAccessTokenScopes?, forKey key: String = "AccessTokenInfo") -> Bool {
    if let data = try? PropertyListEncoder().encode(AccessTokenInfo(accessToken: accessToken, expiry: expiryDate, scopes: scopes)) {
        UserDefaults.standard.set(data, forKey: key)
        return UserDefaults.standard.synchronize()
    }
    return false
}

func getTokenInfo(key: String = "AccessTokenInfo") -> AccessTokenInfo? {
    if let data = UserDefaults.standard.data(forKey: key) {
        let accessTokenInfo = try? PropertyListDecoder().decode(AccessTokenInfo.self, from: data)
        return accessTokenInfo
    }
    return nil
}

func saveQueryParam(queryParam: String, forKey key: String = "QueryParam") -> Bool {
    if let data = try? PropertyListEncoder().encode(QueryParamInfo(queryString: queryParam)) {
        UserDefaults.standard.set(data, forKey: key)
        return UserDefaults.standard.synchronize()
    }
    return false
}

func getQueryParam(key: String = "QueryParam") -> String {
    if let data = UserDefaults.standard.data(forKey: key) {
        let queryParam = try? PropertyListDecoder().decode(QueryParamInfo.self, from: data)
        return queryParam?.queryString ?? ""
    }
    return ""
}

func saveMiniAppLaunchInfo(isMiniAppLaunched: Bool, forKey key: String = "MAFirstTimeLaunch") -> Bool {
    if let data = try? PropertyListEncoder().encode(MiniAppLaunchInfo(isLaunchedAlready: isMiniAppLaunched)) {
        UserDefaults.standard.set(data, forKey: key)
        return UserDefaults.standard.synchronize()
    }
    return false
}

func isMiniAppLaunchedAlready(key: String = "MAFirstTimeLaunch") -> Bool {
    if let data = UserDefaults.standard.data(forKey: key) {
        let launchInfo = try? PropertyListDecoder().decode(MiniAppLaunchInfo.self, from: data)
        return launchInfo?.isLaunchedAlready ?? false
    }
    return false
}
