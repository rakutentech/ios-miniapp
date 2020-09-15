struct MiniAppErrorDetail: Codable, Error {
    let name: String
    let description: String
}

enum MiniAppErrorType: String, Codable, MiniAppErrorProtocol {
    case hostAppError
    case unknownError

    var name: String {
        return self.rawValue
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

func getMiniAppErrorMessage<T: MiniAppErrorProtocol>(_ error: T) -> String {
    return "\(error.name): \(error.description)"
}

enum MiniAppJavaScriptError: String, Codable, MiniAppErrorProtocol {
    case internalError
    case unexpectedMessageFormat
    case invalidPermissionType
    case valueIsEmpty

    var name: String {
        return self.rawValue
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
        }
    }
}
