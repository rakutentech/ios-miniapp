struct MiniAppError: Codable {
    let error: MiniAppErrorDetail
}

struct MiniAppErrorDetail: Codable, Error {
    let title: String
    let description: String
}

enum MiniAppErrorType: String, Codable, MiniAppErrorProtocol {
    case hostAppError
    case unknownError

    var name: String {
        return self.rawValue
    }

    public var message: String {
        switch self {
        case .hostAppError:
        return "Host app Error"
        case .unknownError:
        return "Unknown error occurred, please try again"
        }
    }
}

func getMiniAppErrorMessage<T: MiniAppErrorProtocol>(_ error: T) -> String {
    return getErrorJsonResponse(error: MiniAppError(error: MiniAppErrorDetail(title: error.name, description: error.message)))
}

func getErrorJsonResponse(error: MiniAppError) -> String {
    do {
        let jsonData = try JSONEncoder().encode(error)
        return String(data: jsonData, encoding: .utf8)!
    } catch let error {
        return error.localizedDescription
    }
}

public enum MiniAppPermissionResult: Error {
    /// User has explicitly denied authorization
    case denied
    /// User has not yet made a choice
    case notDetermined
    /// Host app is not authorized to use location services
    case restricted
}

extension MiniAppPermissionResult: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .denied:
            return NSLocalizedString("Denied", comment: "Permission Error")
        case .notDetermined:
            return NSLocalizedString("NotDetermined", comment: "Permission Error")
        case .restricted:
            return NSLocalizedString("Restricted", comment: "Permission Error")
        }
    }
}

enum MiniAppJavaScriptError: String, Codable, MiniAppErrorProtocol {
    case internalError
    case unexpectedMessageFormat
    case invalidPermissionType

    var name: String {
        return self.rawValue
    }

    var message: String {
        switch self {
        case .internalError:
        return "Host app failed to retrieve data"
        case .unexpectedMessageFormat:
        return "Please check the message format that is sent to Javascript SDK."
        case .invalidPermissionType:
        return "Permission type that is requested is invalid"
        }
    }
}
