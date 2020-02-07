extension NSError {

    class func serverError(code: Int, message: String) -> NSError {
        return NSError(
            domain: "APIClient",
            code: code,
            userInfo: [NSLocalizedDescriptionKey: message]
        )
    }

    class func unknownServerError(httpResponse: HTTPURLResponse?) -> NSError {
        return NSError.serverError(
            code: (httpResponse)?.statusCode ?? 0,
            message: "Unknown server error occurred"
        )
    }

    class func invalidURLError() -> NSError {
        return NSError(
            domain: "APIClient",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "Invalid URL error"]
        )
    }

    class func invalidResponseData() -> NSError {
        return NSError(
            domain: "APIClient",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "Invalid response received"]
        )
    }

    class func downloadingFailed() -> NSError {
        return NSError(
            domain: "Downloader",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "Downloading failed"]
        )
    }
}
