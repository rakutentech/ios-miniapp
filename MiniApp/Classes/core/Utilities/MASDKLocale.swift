/// This structure provides different enums for localizable strings related to Mini App SDK
// swiftlint:disable identifier_name
public struct MASDKLocale {
    /// This enum provides MiniApp UI and error related strings keys
    public enum LocalizableKey: String {
        case ok                                     = "miniapp.sdk.ios.alert.title.ok"
        case cancel                                 = "miniapp.sdk.ios.alert.title.cancel"
        case allow                                  = "miniapp.sdk.ios.ui.allow"
        case save                                   = "miniapp.sdk.all.ui.save"
        case customSettingsFooter                   = "miniapp.sdk.ios.customsettingsfooter"
        case firstLaunchFooter                      = "miniapp.sdk.ios.firstlaunch.footer"
        case serverError                            = "miniapp.sdk.ios.error.message.server"
        case invalidUrl                             = "miniapp.sdk.ios.error.message.invalid_url"
        case invalidAppId                           = "miniapp.sdk.ios.error.message.invalid_app_id"
        case invalidVersionId                       = "miniapp.sdk.ios.error.message.invalid_version_id"
        case invalidContactId                       = "miniapp.sdk.ios.error.message.invalid_contact_id"
        case invalidResponse                        = "miniapp.sdk.ios.error.message.invalid_response"
        case downloadFailed                         = "miniapp.sdk.ios.error.message.download_failed"
        case noPublishedVersion                     = "miniapp.sdk.ios.error.message.no_published_version"
        case miniappIdNotFound                      = "miniapp.sdk.ios.error.message.miniapp_id_not_found"
        case metaDataRequiredPermissionsFailure     = "miniapp.sdk.ios.error.message.miniapp_meta_data_required_permissions_failure"
        case unknownError                           = "miniapp.sdk.ios.error.message.unknown"
        case hostAppError                           = "miniapp.sdk.ios.error.message.host_app"
        case failedToConformToProtocol              = "miniapp.sdk.ios.error.message.failed_to_conform_to_protocol"
        case unknownServerError                     = "miniapp.sdk.ios.error.message.unknown_server_error"
        case adNotLoadedError                       = "miniapp.sdk.ios.error.message.ad_not_loaded"
        case adLoadingError                         = "miniapp.sdk.ios.error.message.ad_loading"
        case adLoadedError                          = "miniapp.sdk.ios.error.message.ad_loaded"
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
        if params.count > 0 {
            return localize(bundle: path, key.rawValue, params.first!)
        } else {
            return localize(bundle: path, key.rawValue, params)
        }
    }
}
