struct MiniAppErrorDetail: Codable, Error {
    let name: String
    let description: String
}

enum MiniAppErrorType: String, Codable, MiniAppErrorProtocol {
    case hostAppError
    case unknownError

    var name: String {
        self.rawValue
    }

    public var description: String {
        switch self {
        case .hostAppError:
        return "Host app Error"
        case .unknownError:
        return "Unknown error occurred, please try again"
        }
    }
}

struct MAJavascriptErrorModel: Codable {
    var type: String?
    var message: String?
}

enum MiniAppJavaScriptError: String, Codable, MiniAppErrorProtocol {
    case internalError
    case unexpectedMessageFormat
    case invalidPermissionType
    case valueIsEmpty
    case scopeError
    case audienceError

    var name: String {
        self.rawValue
    }

    var description: String {
        switch self {
        case .internalError:
        return "Host app failed to retrieve data"
        case .unexpectedMessageFormat:
        return "Please check the message format that is sent to Javascript SDK."
        case .invalidPermissionType:
        return "Permission type that is requested is invalid"
        case .valueIsEmpty:
        return "The value which is passed is empty."
        case .scopeError:
        return "No scopes provided for the audience requested"
        case .audienceError:
        return "Audience with scopes requested not allowed on this MiniApp"
        }
    }
}
