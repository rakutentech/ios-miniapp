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

    /// ZIP archive signature has changed during download phase
    case invalidSignature

    /// Error code to let the Host app know that Mini app is modified or corrupted after downloading
    case miniAppCorrupted

    /// An unexpected error occurred.
    ///
    /// - Parameters:
    ///     - domain: The domain from the original NSError.
    ///     - message: The code from the original NSError.
    ///     - description: The description from the original NSError
    case unknownError(domain: String, code: Int, description: String)

    case miniAppTooManyRequestsError

    /// Checks if the error is due to the Internet availability, returns true if yes
    /// - Returns: Bool value - returns true if there is there error contains code from offlineErrorCodeList
    public func isDeviceOfflineDownloadError() -> Bool {
        if case .unknownError(_, let code, _) = self {
            return offlineErrorCodeList.contains(code)
        }
        return false
    }

    /// Method to know if MASDKerror is because of exceeding QPS limit set on the platfom side
    /// - Returns: Bool value - True if it exceeded the limit
    public func isQPSLimitError() -> Bool {
        if case .miniAppTooManyRequestsError = self {
            return true
        }
        return false
    }
}

extension MASDKError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .serverError(let code, let message):
            return String(format: MASDKLocale.localize(.serverError), "\(code)", message)
        case .invalidURLError:
            return MASDKLocale.localize(.invalidUrl)
        case .invalidAppId:
            return MASDKLocale.localize(.invalidAppId)
        case .invalidSignature:
            return MASDKLocale.localize(.signatureFailed)
        case .invalidVersionId:
            return MASDKLocale.localize(.invalidVersionId)
        case .invalidResponseData:
            return MASDKLocale.localize(.invalidResponse)
        case .downloadingFailed:
            return MASDKLocale.localize(.downloadFailed)
        case .noPublishedVersion:
            return MASDKLocale.localize(.noPublishedVersion)
        case .miniAppNotFound:
            return MASDKLocale.localize(.miniappIdNotFound)
        case .metaDataFailure:
            return MASDKLocale.localize(.metaDataRequiredPermissionsFailure)
        case .failedToConformToProtocol:
            return MASDKLocale.localize(.failedToConformToProtocol)
        case .invalidContactId:
            return MASDKLocale.localize(.invalidContactId)
        case .miniAppCorrupted:
            return MASDKLocale.localize(.miniAppCorrupted)

        case .unknownError(let domain, let code, let description):
            return String(format: MASDKLocale.localize(.unknownError), domain, "\(code)", description)
        case .miniAppTooManyRequestsError:
            return MASDKLocale.localize(.miniAppTooManyRequestsError)
        }
    }

    public var code: Int {
        switch self {
        case .serverError(let code, _):
            return code
        case .unknownError(_, let code, _):
            return code
        default:
            return 0
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
            case .invalidSignature:
                return MASDKError.invalidSignature
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
