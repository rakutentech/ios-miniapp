enum MiniAppJSActionCommand: String {
    case getUniqueId
    case getCurrentPosition
    case requestPermission
    case requestCustomPermissions
}

enum JavaScriptExecResult: String {
    case onSuccess
    case onError
}

enum MiniAppJavaScriptError: String {
    case internalError
    case unexpectedMessageFormat
    case invalidPermissionType
}

enum MiniAppSupportedSchemes: String {
    case tel
}

public enum MiniAppPermissionType: String {
    case location
}

public enum MiniAppCustomPermissionType: String, Codable, CaseIterable {
    case userName = "rakuten.miniapp.user.USER_NAME"
    case profilePhoto = "rakuten.miniapp.user.PROFILE_PHOTO"
    case contactsList = "rakuten.miniapp.user.CONTACT_LIST"

    public var title: String {
        switch self {
        case .userName:
        return "User Name"
        case .profilePhoto:
        return "Profile Photo"
        case .contactsList:
        return "Contact List"
        }
    }
}

public enum MiniAppCustomPermissionGrantedStatus: String, Codable {
    case allowed = "ALLOWED"
    case denied = "DENIED"
    case permissionNotAvailable = "PERMISSION_NOT_AVAILABLE"
}

public enum MiniAppPermissionResult: Error {
    case denied
    case notDetermined
    case restricted
}

extension MiniAppPermissionResult: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .denied:
            return NSLocalizedString("Denied", comment: "Permission Error")
        case .notDetermined:
            return NSLocalizedString("NotDetermined", comment: "Permission Error")
        case .restricted:
            return NSLocalizedString("Restricted", comment: "Permission Error")
        }
    }
}
