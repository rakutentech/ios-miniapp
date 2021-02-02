extension NSError {

    class func serverError(code: Int, message: String) -> NSError {
        switch code {
        case 404:
            return miniAppNotFound(message: message)
        default:
            return NSError(
                    domain: MiniAppSDKServerErrorDomain,
                    code: code,
                    userInfo: [NSLocalizedDescriptionKey: message]
            )
        }
    }

    class func unknownServerError(httpResponse: HTTPURLResponse?) -> NSError {
        return NSError.serverError(
                code: (httpResponse)?.statusCode ?? 0,
                message: "Unknown server error occurred"
        )
    }

    class func invalidURLError() -> NSError {
        return NSError(
                domain: MiniAppSDKErrorDomain,
                code: MiniAppSDKErrorCode.invalidURLError.rawValue
        )
    }

    class func invalidAppId() -> NSError {
        return NSError(
                domain: MiniAppSDKErrorDomain,
                code: MiniAppSDKErrorCode.invalidAppId.rawValue
        )
    }

    class func invalidResponseData() -> NSError {
        return NSError(
                domain: MiniAppSDKErrorDomain,
                code: MiniAppSDKErrorCode.invalidResponseData.rawValue
        )
    }

    class func downloadingFailed() -> NSError {
        return NSError(
                domain: MiniAppSDKErrorDomain,
                code: MiniAppSDKErrorCode.downloadingFailed.rawValue
        )
    }

    class func noPublishedVersion() -> NSError {
        return NSError(
                domain: MiniAppSDKErrorDomain,
                code: MiniAppSDKErrorCode.noPublishedVersion.rawValue
        )
    }

    class func miniAppNotFound(message: String) -> NSError {
        return NSError(
                domain: MiniAppSDKErrorDomain,
                code: MiniAppSDKErrorCode.miniAppNotFound.rawValue,
                userInfo: [NSLocalizedDescriptionKey: message]
        )
    }

    class func miniAppAdNotLoaded(message: String) -> NSError {
        NSError(
                domain: MiniAppSDKErrorDomain,
                code: MiniAppSDKErrorCode.adNotLoaded.rawValue,
                userInfo: [NSLocalizedDescriptionKey: message]
        )
    }

    class func miniAppAdNotDisplayed(message: String) -> NSError {
        NSError(
                domain: MiniAppSDKErrorDomain,
                code: MiniAppSDKErrorCode.adNotDisplayed.rawValue,
                userInfo: [NSLocalizedDescriptionKey: message]
        )
    }

    class func miniAppAdProtocoleError() -> NSError {
        NSError(
                domain: MiniAppSDKErrorDomain,
                code: MiniAppSDKErrorCode.adNotDisplayed.rawValue,
                userInfo: [NSLocalizedDescriptionKey: MASDKAdsDisplayError.failedToConformToProtocol.localizedDescription]
        )
    }

    class func genericError(message: String, code: Int = 0) -> NSError {
        return NSError.serverError(
                code: code,
                message: message)
    }
}
// swiftlint:disable identifier_name
var MiniAppSDKErrorDomain = "MiniAppSDKErrorDomain"
var MiniAppSDKServerErrorDomain = "MiniAppSDKServerErrorDomain"

enum MiniAppSDKErrorCode: Int {
    case invalidURLError = 1,
         invalidAppId,
         invalidResponseData,
         downloadingFailed,
         noPublishedVersion,
         miniAppNotFound
}
