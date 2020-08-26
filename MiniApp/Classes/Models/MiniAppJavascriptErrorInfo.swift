struct MiniAppError: Codable {
    let error: MiniAppErrorDetail
}

struct MiniAppErrorDetail: Codable, Error {
    let title: MiniAppCustomPermissionError
    let description: String
}

public enum MiniAppCustomPermissionError: String, Codable {
    case invalidCustomPermissionRequest
    case invalidCustomPermissionsList
    case hostAppError
    case unknownError

    public var description: String {
        switch self {
        case .invalidCustomPermissionRequest:
        return "Error in Custom Permission Request, please make sure the Custom permissions are passed in []"
        case .invalidCustomPermissionsList:
        return "Error in list of Custom permissions that is passed, please check whether valid permission associated with name "
        case .hostAppError:
        return ""
        case .unknownError:
        return "Unknown error occurred, please try again"
        }
    }
}

func getMiniAppCustomPermissionError(customPermissionError: MiniAppCustomPermissionError) -> String {
    return getErrorJsonResponse(error: MiniAppError(error: MiniAppErrorDetail(title: customPermissionError, description: customPermissionError.description)))
}

func getErrorJsonResponse(error: MiniAppError) -> String {
    do {
        let jsonData = try JSONEncoder().encode(error)
        return String(data: jsonData, encoding: .utf8)!
    } catch let error {
        return error.localizedDescription
    }
}
