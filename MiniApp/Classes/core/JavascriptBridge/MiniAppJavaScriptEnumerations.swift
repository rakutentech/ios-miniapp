enum MiniAppJSActionCommand: String {
    case getUniqueId
    case getCurrentPosition
    case requestPermission
    case requestCustomPermissions
    case shareInfo
    case getUserName
    case getProfilePhoto
    case setScreenOrientation
    case getAccessToken
    case loadAd
    case showAd
    case getContacts
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
public enum MiniAppDevicePermissionType: String {
    /// Device Location permission type. Host app is expected to implement the logic only for requesting the location permission.
    case location
}

public enum MiniAppCustomPermissionType: String, Codable, CaseIterable {
    case userName = "rakuten.miniapp.user.USER_NAME"
    case profilePhoto = "rakuten.miniapp.user.PROFILE_PHOTO"
    case contactsList = "rakuten.miniapp.user.CONTACT_LIST"
    case accessToken = "rakuten.miniapp.user.ACCESS_TOKEN"
    case deviceLocation = "rakuten.miniapp.device.LOCATION"

    public var title: String {
        switch self {
        case .userName:
            return "User Name"
        case .profilePhoto:
            return "Profile Photo"
        case .contactsList:
            return "Contact List"
        case .accessToken:
            return "Access Token"
        case .deviceLocation:
            return "Device Location"
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

/// This enum is used by [MiniAppAdDisplayer](x-source-tag://MiniAppAdDisplayer) to know which kind of ad is manipulated
enum MiniAppAdType: Int {
    /// Interstitial ads are interactive, full-screen ads that cover the interface of their host app
    case interstitial = 0
    /// Rewarded ads are interstistial ads that provide a pre-defined reward to the user if they display it for a certain time
    case rewarded
}
