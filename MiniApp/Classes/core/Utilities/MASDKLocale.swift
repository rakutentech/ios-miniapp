/// This structure provides different enums for localizable strings related to Mini App SDK
// swiftlint:disable identifier_name
public struct MASDKLocale {
    /// This enum provides MiniApp UI and error related strings keys
    public enum LocalizableKey: String {
        case ok                                     = "miniapp_sdk_ios_alert_title_ok"
        case cancel                                 = "miniapp_sdk_ios_alert_title_cancel"
        case allow                                  = "miniapp_sdk_ios_ui_allow"
        case save                                   = "miniapp_sdk_ios_ui_save"
        case firstLaunchFooter                      = "miniapp_sdk_ios_firstlaunch_footer"
        case serverError                            = "miniapp_sdk_ios_error_message_server"
        case invalidUrl                             = "miniapp_sdk_ios_error_message_invalid_url"
        case invalidAppId                           = "miniapp_sdk_ios_error_message_invalid_app_id"
        case invalidVersionId                       = "miniapp_sdk_ios_error_message_invalid_version_id"
        case invalidContactId                       = "miniapp_sdk_ios_error_message_invalid_contact_id"
        case invalidResponse                        = "miniapp_sdk_ios_error_message_invalid_response"
        case downloadFailed                         = "miniapp_sdk_ios_error_message_download_failed"
        case noPublishedVersion                     = "miniapp_sdk_ios_error_message_no_published_version"
        case miniappIdNotFound                      = "miniapp_sdk_ios_error_message_miniapp_id_not_found"
        case metaDataRequiredPermissionsFailure     = "miniapp_sdk_ios_error_message_miniapp_meta_data_required_permissions_failure"
        case unknownError                           = "miniapp_sdk_ios_error_message_unknown"
        case hostAppError                           = "miniapp_sdk_ios_error_message_host_app"
        case failedToConformToProtocol              = "miniapp_sdk_ios_error_message_failed_to_conform_to_protocol"
        case unknownServerError                     = "miniapp_sdk_ios_error_message_unknown_server_error"
        case adNotLoadedError                       = "miniapp_sdk_ios_error_message_ad_not_loaded"
        case adLoadingError                         = "miniapp_sdk_ios_error_message_ad_loading"
        case adLoadedError                          = "miniapp_sdk_ios_error_message_ad_loaded"
    }

    public static func localize(bundle path: String? = nil, _ key: String, _ params: CVarArg...) -> String {
        let localizedString: String
        if let path = path {
            localizedString = key.localizedString(path: path)
        } else {
            localizedString = key.localizedString()
        }
        if params.count > 0 {
            return String(format: localizedString, arguments: params)
        }
        return localizedString
    }

    public static func localize(bundle path: String? = nil, _ key: LocalizableKey, _ params: CVarArg...) -> String {
        localize(bundle: path, key.rawValue, params)
    }
}
