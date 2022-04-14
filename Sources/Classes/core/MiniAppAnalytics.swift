import Foundation

internal enum MiniAppRATEventType: String, CaseIterable {
    case appear
    case click
    case custom
}

internal enum MiniAppRATEvent: String, CaseIterable {
    case hostLaunch = "host_launch"
    case open
    case close
    case signatureFailure = "mini_app_signature_validation_fail"
    case getUniqueId = "mini_app_get_unique_id"
    case getMessagingUniqueId = "mini_app_get_messaging_unique_id"
    case getMauid = "mini_app_get_mauid"
    case getCurrentPosition = "mini_app_get_current_position"
    case requrestPermission = "mini_app_request_permission"
    case requrestCustomPermission = "mini_app_request_custom_permission"
    case shareInfo = "mini_app_share_info"
    case loadAd = "mini_app_load_ad"
    case showAd = "mini_app_show_ad"
    case getuserName = "mini_app_show_user_name"
    case getProfilePhoto = "mini_app_get_profile_photo"
    case getAccessToken = "mini_app_get_access_token"
    case getPoints = "mini_app_get_points"
    case setScreenOrientation = "mini_app_set_screen_orientation"
    case getContacts = "mini_app_get_contacts"
    case sendMessageToContact = "mini_app_send_message_to_contact"
    case sendMessageToContactId = "mini_app_send_message_to_contact_id"
    case sendMessageToMultipleContacts = "mini_app_send_message_to_multiple_contacts"
    case getEnvironemtnInfo = "mini_app_get_environment_info"
    case purchaseItem = "mini_app_purchase_product"
    case downloadFile = "mini_app_download_file"

    func name() -> String {
        "mini_app_\(rawValue)"
    }

    func eType() -> MiniAppRATEventType {
        switch self {
        case .signatureFailure:
            return .click
        case .hostLaunch:
            return .appear
        case .open, .close:
            return .click
        case .getUniqueId,
             .getMessagingUniqueId,
             .getMauid,
             .getCurrentPosition,
             .requrestPermission,
             .requrestCustomPermission,
             .shareInfo,
             .loadAd,
             .showAd,
             .getuserName,
             .getProfilePhoto,
             .getAccessToken,
             .getPoints,
             .setScreenOrientation,
             .getContacts,
             .sendMessageToContact,
             .sendMessageToContactId,
             .sendMessageToMultipleContacts,
             .getEnvironemtnInfo,
             .downloadFile,
             .purchaseItem:
            return .click
        }
    }
}

internal enum MiniAppAnalyticsParameter: String, CaseIterable {
    case projectId = "project_id"
    case miniAppId = "id"
    case versionId = "version_id"
    case sdkVersion = "sdk_version"

    func name() -> String {
        "mini_app_\(rawValue)"
    }
}

// Call `MiniApp.configure()` at start to load analytics
public class MiniAppAnalyticsLoader: NSObject {
    @objc public static func loadMiniAppAnalytics() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            MiniAppAnalytics.sendAnalytics(event: .hostLaunch)
        }
    }
}

public class MiniAppAnalytics {
    public static let notificationName = Notification.Name("com.rakuten.esd.sdk.events.custom")
    open class var sdkVersion: String? {
        Bundle.miniAppSDKBundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? MiniApp.version
    }
    internal static let defaultRATAcc = MAAnalyticsConfig(acc: "1553", aid: "1")

    internal class func getAnalyticsInfo(miniAppId: String? = nil, miniAppVersion: String? = nil, projectId: String? = nil) -> [(String, String)] {
        var result = [(String, String)]()
        if let miniAppId = miniAppId {
            result.append((MiniAppAnalyticsParameter.miniAppId.name(), miniAppId))
        }
        if let version = miniAppVersion {
            result.append((MiniAppAnalyticsParameter.versionId.name(), version))
        }
        if let projectId = projectId ?? Bundle.main.value(for: Environment.Key.projectId.rawValue) {
            result.append((MiniAppAnalyticsParameter.projectId.name(), projectId))
        }
        if let version = sdkVersion {
            result.append((MiniAppAnalyticsParameter.sdkVersion.name(), version))
        }
        return result
    }

    internal class func getAnalyticsConfigList(analyticsConfig: [MAAnalyticsConfig]? = []) -> [MAAnalyticsConfig] {
        var analyticsConfigList: [MAAnalyticsConfig] = []
        analyticsConfigList.append(defaultRATAcc)
        guard let configList = analyticsConfig else {
            return analyticsConfigList
        }
        analyticsConfigList.append(contentsOf: configList)
        return analyticsConfigList
    }

    internal class func sendAnalytics(event: MiniAppRATEvent, miniAppId: String? = nil, miniAppVersion: String? = nil, projectId: String? = nil, customParameters: (String, String)..., analyticsConfig: [MAAnalyticsConfig]? = []) {
        let params = getAnalyticsInfo(miniAppId: miniAppId, miniAppVersion: miniAppVersion, projectId: projectId) + customParameters
        MiniAppLogger.d("posting \(event.name()) analytic \(event.eType()) event with params:\n\(params)", "📡")
        NotificationCenter.default.sendAnalytics(event: event, parameters: params, analyticsConfig: getAnalyticsConfigList(analyticsConfig: analyticsConfig))
    }

    internal class func sendAnalytics(command: MiniAppJSActionCommand) {
        guard let ratEvent = getRatEvent(for: command) else {
            MiniAppLogger.e("invalid tracking for \(command)")
            return
        }
        sendAnalytics(event: ratEvent)
    }

    // swiftlint:disable function_body_length
    private class func getRatEvent(for command: MiniAppJSActionCommand) -> MiniAppRATEvent? {
        switch command {
        case .getUniqueId:
            return .getUniqueId
        case .getMessagingUniqueId:
            return .getMessagingUniqueId
        case .getMauid:
            return .getMauid
        case .getCurrentPosition:
            return .getCurrentPosition
        case .requestPermission:
            return .requrestPermission
        case .requestCustomPermissions:
            return .requrestCustomPermission
        case .shareInfo:
            return .shareInfo
        case .getUserName:
            return .getuserName
        case .getProfilePhoto:
            return .getProfilePhoto
        case .setScreenOrientation:
            return .setScreenOrientation
        case .getAccessToken:
            return .getAccessToken
        case .loadAd:
            return .loadAd
        case .showAd:
            return .showAd
        case .getContacts:
            return .getContacts
        case .sendMessageToContact:
            return .sendMessageToContact
        case .sendMessageToContactId:
            return .sendMessageToContactId
        case .sendMessageToMultipleContacts:
            return .sendMessageToMultipleContacts
        case .getPoints:
            return .getPoints
        case .getHostEnvironmentInfo:
            return .getEnvironemtnInfo
        case .downloadFile:
            return .downloadFile
        case .purchaseItem:
            return .purchaseItem
        }
    }
}
