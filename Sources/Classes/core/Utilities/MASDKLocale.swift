// swiftlint:disable identifier_name
/// This structure provides different enums for localizable strings related to Mini App SDK
public struct MASDKLocale {
    /// This enum provides MiniApp UI and error related strings keys
    public enum LocalizableKey: String {
        /// Localizable key for Ok text
        case ok                                     = "miniapp.sdk.ios.alert.title.ok"
        /// Localizable key for Cancel text
        case cancel                                 = "miniapp.sdk.ios.alert.title.cancel"
        /// Localizable key for Allow text
        case allow                                  = "miniapp.sdk.ios.ui.allow"
        /// Localizable key for Save text
        case save                                   = "miniapp.sdk.all.ui.save"
        /// Localizable key that is used at the bottom of the permissions validation screen
        case firstLaunchFooter                      = "miniapp.sdk.ios.firstlaunch.footer"
        /// Localizable key for Edit text
        case settingsUserProfileEdit                = "miniapp.sdk.ios.page.settings.userprofile.save"
        /// Localizable key for Save text
        case settingsUserProfileSave                = "miniapp.sdk.ios.page.settings.userprofile.edit"
        /// Localizable key for Add text
        case settingsUserProfileAdd                 = "miniapp.sdk.ios.page.settings.userprofile.add"
        /// Localizable key for Remove text
        case settingsUserProfileDelete              = "miniapp.sdk.ios.page.settings.userprofile.remove"
        /// Localizable key for Server error text
        case serverError                            = "miniapp.sdk.ios.error.message.server"
        /// Localizable key for displaying error if URL is invalid
        case invalidUrl                             = "miniapp.sdk.ios.error.message.invalid_url"
        /// Localizable key for displaying error if Mini app ID is invalid
        case invalidAppId                           = "miniapp.sdk.ios.error.message.invalid_app_id"
        /// Localizable key for displaying error if Mini app version is invalid
        case invalidVersionId                       = "miniapp.sdk.ios.error.message.invalid_version_id"
        /// Localizable key for displaying error if Contact ID is invalid
        case invalidContactId                       = "miniapp.sdk.ios.error.message.invalid_contact_id"
        /// Localizable key for displaying error for invalid response text
        case invalidResponse                        = "miniapp.sdk.ios.error.message.invalid_response"
        /// Localizable key for displaying for downloading failed error
        case downloadFailed                         = "miniapp.sdk.ios.error.message.download_failed"
        /// Localizable key for displaying Signature verification failed error
        case signatureFailed                        = "miniapp.sdk.ios.error.message.signature_failed"
        /// Localizable key for displaying error if Mini app is corrupted
        case miniAppCorrupted                       = "miniapp.sdk.ios.error.message.miniapp_corrupted"
        /// Localizable key for displaying error if no published version of mini app is found
        case noPublishedVersion                     = "miniapp.sdk.ios.error.message.no_published_version"
        /// Localizable key for displaying error if provided mini app ID is not found in platform
        case miniappIdNotFound                      = "miniapp.sdk.ios.error.message.miniapp_id_not_found"
        /// Localizable key for displaying error if all required permissions are allowed by the user
        case metaDataRequiredPermissionsFailure     = "miniapp.sdk.ios.error.message.miniapp_meta_data_required_permissions_failure"
        /// Localizable key for displaying unknown error
        case unknownError                           = "miniapp.sdk.ios.error.message.unknown"
        /// Localizable key for displaying error with the Host app
        case hostAppError                           = "miniapp.sdk.ios.error.message.host_app"
        /// Localizable key for displaying error if Host app failed to conform to protocol methods
        case failedToConformToProtocol              = "miniapp.sdk.ios.error.message.failed_to_conform_to_protocol"
        /// Localizable key for displaying unknown errors from Server
        case unknownServerError                     = "miniapp.sdk.ios.error.message.unknown_server_error"
        /// Localizable key for displaying error if Add failed to load
        case adNotLoadedError                       = "miniapp.sdk.ios.error.message.ad_not_loaded"
        /// Localizable key for displaying error if Add is failed while loading
        case adLoadingError                         = "miniapp.sdk.ios.error.message.ad_loading"
        /// Localizable key for displaying error after Ad is loaded
        case adLoadedError                          = "miniapp.sdk.ios.error.message.ad_loaded"
        /// Localizable key for Navigation Close button
        case uiNavButtonClose                       = "miniapp.sdk.ios.ui.nav.button.close"
        /// Localizable key for Navigation title
        case uiFallbackTitle                        = "miniapp.sdk.ios.ui.fallback.title"
        /// Localizable key for Navigation Retry button
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
