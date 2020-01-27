extension NSError {

    class func serverError(code: Int, message: String) -> NSError {
        return NSError(
            domain: "APIClient",
            code: code,
            userInfo: [NSLocalizedDescriptionKey: message]
        )
    }

    class func unknownServerError(httpResponse: HTTPURLResponse?) -> NSError {
        let unknownError = NSError.serverError(
            code: (httpResponse)?.statusCode ?? 0,
            message: "Unknown server error occurred"
        )
        return unknownError
    }

    class func invalidURLError() -> NSError {
        return NSError(
            domain: "API Client",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "Invalid URL error"]
        )
    }
}
