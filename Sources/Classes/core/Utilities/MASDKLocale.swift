/// This structure provides different enums for localizable strings related to Mini App SDK
// swiftlint:disable identifier_name
public struct MASDKLocale {
    /// This enum provides MiniApp UI and error related strings keys
    public enum LocalizableKey: String {
        case ok                                     = "miniapp.sdk.ios.alert.title.ok"
        case cancel                                 = "miniapp.sdk.ios.alert.title.cancel"
        case allow                                  = "miniapp.sdk.ios.ui.allow"
        case save                                   = "miniapp.sdk.all.ui.save"
        case firstLaunchFooter                      = "miniapp.sdk.ios.firstlaunch.footer"
        case settingsUserProfileEdit                = "miniapp.sdk.ios.page.settings.userprofile.save"
        case settingsUserProfileSave                = "miniapp.sdk.ios.page.settings.userprofile.edit"
        case settingsUserProfileAdd                 = "miniapp.sdk.ios.page.settings.userprofile.add"
        case settingsUserProfileDelete              = "miniapp.sdk.ios.page.settings.userprofile.remove"
        case serverError                            = "miniapp.sdk.ios.error.message.server"
        case invalidUrl                             = "miniapp.sdk.ios.error.message.invalid_url"
        case invalidAppId                           = "miniapp.sdk.ios.error.message.invalid_app_id"
        case invalidVersionId                       = "miniapp.sdk.ios.error.message.invalid_version_id"
        case invalidSDKId                           = "miniapp.sdk.ios.error.message.invalid_sdk_id"
        case invalidContactId                       = "miniapp.sdk.ios.error.message.invalid_contact_id"
        case invalidResponse                        = "miniapp.sdk.ios.error.message.invalid_response"
        case downloadFailed                         = "miniapp.sdk.ios.error.message.download_failed"
        case signatureFailed                        = "miniapp.sdk.ios.error.message.signature_failed"
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
        case uiNavButtonClose                       = "miniapp.sdk.ios.ui.nav.button.close"
        case uiFallbackTitle                        = "miniapp.sdk.ios.ui.fallback.title"
        case uiFallbackButtonRetry                  = "miniapp.sdk.ios.ui.fallback.button.retry"
    }

    /// Method to retrieve a localizable from its key
    ///
    /// - Parameters:
    ///   - path: the optional path to the bundle where the strings file is located
    ///   - key: the key that defines the localizable in the strings file
    /// - Returns:
    public static func localize(bundle path: String? = nil, _ key: String) -> String {
        let localizedString: String
        if let path = path {
            localizedString = key.localizedString(path: path)
        } else {
            localizedString = key.localizedString()
        }
        return localizedString
    }

    /// Method to retrieve a MiniApp SDK localizable from its key
    ///
    /// - Parameters:
    ///   - path: the optional path to the bundle where the strings file is located
    ///   - key: a LocalizableKey that defines the localizable in the strings file
    /// - Returns:
    public static func localize(bundle path: String? = nil, _ key: LocalizableKey) -> String {
        localize(bundle: path, key.rawValue)
    }
}
