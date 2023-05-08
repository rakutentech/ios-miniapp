import UIKit

enum MiniAppJSActionCommand: String {
    case getUniqueId
    case getMessagingUniqueId
    case getMauid
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
    case sendMessageToContact
    case sendMessageToContactId
    case sendMessageToMultipleContacts
    case getPoints
    case getHostEnvironmentInfo
    case downloadFile
    case getSecureStorageItem
    case setSecureStorageItems
    case removeSecureStorageItems
    case clearSecureStorage
    case getSecureStorageSize
    case setCloseAlert
    case sendJsonToHostapp
    case closeMiniApp
    case getHostAppThemeColors
}

enum JavaScriptExecResult: String {
    case onSuccess
    case onError
}

enum MiniAppSupportedSchemes: String {
    case tel // used for phone calls
    case about // used to reveal internal state and built-in functions (e.g.: alert dialog)
    case mailto // used for e-mails
    case itmsapps = "itms-apps" // used for app-store links
}

/// List of Device Permissions supported by the SDK that can be requested by a Mini app
public enum MiniAppDevicePermissionType: String {
    /// Device Location permission type. Host app is expected to implement the logic only for requesting the location permission.
    case location
}

/// Enumerations of Mini App Custom permission types that is used/checked by the MiniApp SDK before accessing any data from the host app
public enum MiniAppCustomPermissionType: String, Codable, CaseIterable {
    /// Custom permission for retrieving User name from the host app
    case userName = "rakuten.miniapp.user.USER_NAME"
    /// Custom permission for retrieving Profile photo from the host app
    case profilePhoto = "rakuten.miniapp.user.PROFILE_PHOTO"
    /// Custom permission for retrieving List of contacts from the host app
    case contactsList = "rakuten.miniapp.user.CONTACT_LIST"
    /// Custom permission for retrieving Access token details from the host app
    case accessToken = "rakuten.miniapp.user.ACCESS_TOKEN"
    /// Custom permission to send a message via the Host app
    case sendMessage = "rakuten.miniapp.user.action.SEND_MESSAGE"
    /// Custom permission for retrieving device location details from the host app
    case deviceLocation = "rakuten.miniapp.device.LOCATION"
    /// Custom permission for retrieving points from the host app
    case points = "rakuten.miniapp.user.POINTS"
    /// Custom permission for downloading files
    case fileDownload = "rakuten.miniapp.device.FILE_DOWNLOAD"

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
        case .sendMessage:
            return "Send Message"
        case .points:
            return "Rakuten Points"
        case .fileDownload:
            return "File Download"
        }
    }
}

public enum MiniAppCustomPermissionGrantedStatus: String, Codable {
    case allowed = "ALLOWED"
    case denied = "DENIED"
    case permissionNotAvailable = "PERMISSION_NOT_AVAILABLE"

    public var boolValue: Bool {
        return self == .allowed
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

public enum MiniAppEvent: String {
    case externalWebViewClosed = "miniappwebviewclosed"
    case pause = "miniapppause"
    case resume = "miniappresume"
    case secureStorageReady = "miniappsecurestorageready"
    case secureStorageError = "miniappsecurestorageloaderror"
    case miniappReceiveJsonString = "miniappreceivejsoninfo"

    public static let notificationName = Notification.Name("MiniAppNotificationEvent")

    public struct Event {
        var miniAppId: String
        var miniAppVersion: String
        var type: MiniAppEvent
        var comment: String

        public init(miniAppId: String, miniAppVersion: String, type: MiniAppEvent, comment: String) {
            self.miniAppId = miniAppId
            self.miniAppVersion = miniAppVersion
            self.type = type
            self.comment = comment
        }
    }
}

public enum MiniAppKeyboardEvent: String {
    case keyboardShown = "miniappkeyboardshown"
    case keyboardHidden = "miniappkeyboardhidden"

    public static let notificationName = Notification.Name("MiniAppKeyboardNotificationEvent")

    public struct Event {
        var type: MiniAppKeyboardEvent
        var comment: String
        var navigationBarHeight: CGFloat?
        var screenHeight: CGFloat?
        var keyboardHeight: CGFloat?

        public init(type: MiniAppKeyboardEvent, comment: String, navigationBarHeight: CGFloat? = nil, keyboardHeight: CGFloat? = nil, screenHeight: CGFloat? = nil) {
            self.type = type
            self.comment = comment
            self.navigationBarHeight = navigationBarHeight
            self.keyboardHeight = keyboardHeight
            self.screenHeight = screenHeight
        }
    }
}
