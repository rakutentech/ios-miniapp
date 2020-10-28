enum MiniAppJSActionCommand: String {
    case getUniqueId
    case getCurrentPosition
    case requestPermission
    case requestCustomPermissions
    case shareInfo
    case getUserName
    case getProfilePhoto
    case setScreenOrientation
}

enum JavaScriptExecResult: String {
    case onSuccess
    case onError
}

enum MiniAppSupportedSchemes: String {
    case tel // used for phone calls
    case about // used to reveal internal state and built-in functions (e.g.: alert dialog)
}

/// List of Device Permissions supported by the SDK that can be requested by a Mini app
public enum MiniAppPermissionType: String {
    /// Device Location permission type. Host app is expected to implement the logic only for requesting the location permission.
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

    public var boolValue: Bool {
        switch self {
        case .allowed:
            return true
        default:
            return false
        }
    }
}

enum MiniAppInterfaceOrientation: String, Codable {
    case lockPortrait = "rakuten.miniapp.screen.LOCK_PORTRAIT"
    case lockLandscape = "rakuten.miniapp.screen.LOCK_LANDSCAPE"
    case lockRelease = "rakuten.miniapp.screen.LOCK_RELEASE"

    public var orientation: UIInterfaceOrientationMask {
        switch self {
        case .lockPortrait:
            return .portrait
        case .lockLandscape:
            return .landscape
        case .lockRelease:
            return []
        }
    }
}
