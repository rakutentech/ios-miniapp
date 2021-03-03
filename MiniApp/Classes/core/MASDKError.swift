import Foundation

/// Mini App SDK Error which is passed from the main MiniApp APIs.
public enum MASDKError: Error {
    /// The server returned an error.
    ///
    /// - Parameters:
    ///     - code: HTTP status code from the server
    ///     - message: error message returned by the server
    case serverError(code: Int, message: String)

    /// The URL was invalid the SDK tried to connect to the server.
    /// Probably you provided an invalid URL value to the Base URL setting.
    case invalidURLError

    /// The provided mini app ID was invalid. For example, the value cannot be an empty string.
    case invalidAppId

    /// The provided mini app version ID was invalid. For example, the value cannot be an empty string.
    case invalidVersionId

    /// The server provided an invalid response body.
    case invalidResponseData

    /// The mini app failed to download.
    case downloadingFailed

    /// There are no published versions for the provided mini app ID.
    case noPublishedVersion

    /// The provided mini app ID was not found on the server.
    case miniAppNotFound

    /// All required custom permissions is not allowed by the user
    case metaDataFailure

    /// An unexpected error occurred.
    ///
    /// - Parameters:
    ///     - domain: The domain from the original NSError.
    ///     - message: The code from the original NSError.
    ///     - description: The description from the original NSError
    case unknownError(domain: String, code: Int, description: String)
}

extension MASDKError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .serverError(let code, let message):
            return String(format: NSLocalizedString("error_server", comment: ""), code, message)
        case .invalidURLError:
            return NSLocalizedString("error_invalid_url", comment: "")
        case .invalidAppId:
            return NSLocalizedString("error_invalid_app_id", comment: "")
        case .invalidVersionId:
            return NSLocalizedString("error_invalid_version_id", comment: "")
        case .invalidResponseData:
            return NSLocalizedString("error_invalid_response", comment: "")
        case .downloadingFailed:
            return NSLocalizedString("error_download_failed", comment: "")
        case .noPublishedVersion:
            return NSLocalizedString("error_no_published_version", comment: "")
        case .miniAppNotFound:
            return NSLocalizedString("error_miniapp_id_not_found", comment: "")
        case .metaDataFailure:
            return NSLocalizedString("error_miniapp_meta_data_required_permissions_failure", comment: "")
        case .unknownError(let domain, let code, let description):
            return String(format: NSLocalizedString("error_unknown", comment: ""), domain, code, description)
        }
    }
}

extension MASDKError {
    static func fromError(error: Error) -> MASDKError {
        let error = error as NSError
        if error.domain == MiniAppSDKServerErrorDomain {
            return MASDKError.serverError(code: error.code, message: error.userInfo.description)
        }
        if error.domain == MiniAppSDKErrorDomain {
            switch MiniAppSDKErrorCode(rawValue: error.code) {
            case .invalidURLError:
                return MASDKError.invalidURLError
            case .invalidAppId:
                return MASDKError.invalidAppId
            case .invalidResponseData:
                return MASDKError.invalidResponseData
            case .downloadingFailed:
                return MASDKError.downloadingFailed
            case .noPublishedVersion:
                return MASDKError.noPublishedVersion
            case .miniAppNotFound:
                return MASDKError.miniAppNotFound
            case .metaDataFailure:
                return MASDKError.metaDataFailure
            default:
                break
            }
        }
        return MASDKError.unknownError(domain: error.domain, code: error.code, description: error.localizedDescription)
    }
}
