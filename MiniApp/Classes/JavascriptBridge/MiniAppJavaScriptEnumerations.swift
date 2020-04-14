enum MiniAppJSActionCommand: String {
    case getUniqueId
}

enum JavaScriptExecResult: String {
    case onSuccess
    case onError
}

enum MiniAppJavaScriptError: String {
    case internalError
    case unexpectedMessageFormat

    var errorDescription: String? {
        switch self {
        case .internalError:
            return "Unable to process request, please try again later"
        case .unexpectedMessageFormat:
            return "Invalid parameters, please check the value that is passed"
        }
    }
}
