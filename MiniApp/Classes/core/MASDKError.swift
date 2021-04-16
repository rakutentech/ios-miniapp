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

    /// The provided contact ID was invalid. For example, a contact with this ID could not be found in the contact list
    case invalidContactId

    /// Host app failed to implement required interface
    case failedToConformToProtocol

    /// An unexpected error occurred.
    ///
    /// - Parameters:
    ///     - domain: The domain from the original NSError.
    ///     - message: The code from the original NSError.
    ///     - description: The description from the original NSError
    case unknownError(domain: String, code: Int, description: String)

    /// Checks if the error is due to the Internet availability, returns true if yes
    /// - Returns: Bool value - returns true if there is there error contains code from offlineErrorCodeList
    public func isDeviceOfflineDownloadError() -> Bool {
        switch self {
        case .unknownError(_, let code, _):
            return offlineErrorCodeList.contains(code)
        default:
            return false
        }
    }
}

extension MASDKError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .serverError(let code, let message):
            return MiniAppLocalizable.localize(.serverError, code, message)
        case .invalidURLError:
            return MiniAppLocalizable.localize(.invalidUrl)
        case .invalidAppId:
            return MiniAppLocalizable.localize(.invalidAppId)
        case .invalidVersionId:
            return MiniAppLocalizable.localize(.invalidVersionId)
        case .invalidResponseData:
            return MiniAppLocalizable.localize(.invalidResponse)
        case .downloadingFailed:
            return MiniAppLocalizable.localize(.downloadFailed)
        case .noPublishedVersion:
            return MiniAppLocalizable.localize(.noPublishedVersion)
        case .miniAppNotFound:
            return MiniAppLocalizable.localize(.miniappIdNotFound)
        case .metaDataFailure:
            return MiniAppLocalizable.localize(.metaDataRequiredPermissionsFailure)
        case .failedToConformToProtocol:
            return MiniAppLocalizable.localize(.failedToConformToProtocol)
        case .invalidContactId:
            return MiniAppLocalizable.localize(.invalidContactId)

        case .unknownError(let domain, let code, let description):
            return MiniAppLocalizable.localize(.unknownError, domain, code, description)
        }
    }
}

extension MASDKError {
    static func fromError(error: Error) -> MASDKError {
        let error = error as NSError
        if error.domain == MiniAppSDKServerErrorDomain {
            return MASDKError.serverError(code: error.code, message: error.localizedDescription)
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
        if error.domain == MASDKErrorDomain {
            switch MiniAppSDKErrorCode(rawValue: error.code) {
            case .metaDataFailure:
                return MASDKError.metaDataFailure
            default:
                break
            }
        }
        return MASDKError.unknownError(domain: error.domain, code: error.code, description: error.localizedDescription)
    }
}
