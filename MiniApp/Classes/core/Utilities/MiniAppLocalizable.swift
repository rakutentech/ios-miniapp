/// This structure provides different enums for localizable strings related to Mini App SDK
// swiftlint:disable identifier_name
public struct MiniAppLocalizable {
    /// This enum provides MiniApp UI and error related strings
    public enum DefaultText: String {
        case ok = "miniapp.sdk.alert.title.ok"
        case cancel = "miniapp.sdk.alert.title.cancel"
        case allow = "miniapp.sdk.ui.allow"
        case save = "miniapp.sdk.ui.save"
        case customSettingsFooter = "miniapp.sdk.customsettingsfooter"
        case firstLaunchFooter = "miniapp.sdk.firstlaunch.footer"
        case serverError = "miniapp.sdk.error.message.server"
        case invalidUrl = "miniapp.sdk.error.message.invalid_url"
        case invalidAppId = "miniapp.sdk.error.message.invalid_app_id"
        case invalidVersionId = "miniapp.sdk.error.message.invalid_version_id"
        case invalidContactId = "miniapp.sdk.error.message.invalid_contact_id"
        case invalidResponse = "miniapp.sdk.error.message.invalid_response"
        case downloadFailed = "miniapp.sdk.error.message.download_failed"
        case noPublishedVersion = "miniapp.sdk.error.message.no_published_version"
        case miniappIdNotFound = "miniapp.sdk.error.message.miniapp_id_not_found"
        case metaDataRequiredPermissionsFailure = "miniapp.sdk.error.message.miniapp_meta_data_required_permissions_failure"
        case unknownError = "miniapp.sdk.error.message.unknown"
        case hostAppError = "miniapp.sdk.error.message.host_app"
        case failedToConformToProtocol = "miniapp.sdk.error.message.failed_to_conform_to_protocol"
        case unknownServerError = "miniapp.sdk.error.message.unknown_server_error"
        case adNotLoadedError = "miniapp.sdk.error.message.ad_not_loaded"
        case adLoadingError = "miniapp.sdk.error.message.ad_loading"
        case adLoadedError = "miniapp.sdk.error.message.ad_loaded"
    }

    public static func localize(_ key: String, _ params: CVarArg...) -> String {
        let localizedString = key.localizedString()
        if params.count > 0 {
            return String(format: localizedString, arguments: params)
        }
        return localizedString
    }

    public static func localize(_ key: DefaultText, _ params: CVarArg...) -> String {
        localize(key.rawValue, params)
    }
}
