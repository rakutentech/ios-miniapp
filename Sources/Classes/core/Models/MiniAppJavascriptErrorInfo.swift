struct MiniAppErrorDetail: Codable, Error {
    let name: String
    let description: String
}

internal struct MAJSLocationErrorResponseModel: Codable {
    var code: Int
    var message: String?
}

internal struct MAJSDownloadFileErrorResponseModel: Codable {
    var type: String
    var message: String
    var code: Int?
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

public enum MiniAppJavaScriptError: String, Codable, MiniAppErrorProtocol {
    case internalError
    case unexpectedMessageFormat
    case invalidPermissionType
    case valueIsEmpty
    case scopeError
    case audienceError
    case failedToConformToProtocol = "FAILED_TO_CONFORM_PROTOCOL"

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
        case .failedToConformToProtocol:
            return MASDKLocale.localize(.failedToConformToProtocol)
        }
    }
}

/// Enumeration that is used to differentiate the device permission errors
public enum MASDKPermissionError: String, MiniAppErrorProtocol {

    /// User has explicitly denied authorization
    case denied = "DENIED"
    /// User has not yet made a choice
    case notDetermined = "NOT_DETERMINED"
    /// Host app is not authorized to use location services
    case restricted = "RESTRICTED"
    /// Host app failed to implement required interface
    case failedToConformToProtocol = "FAILED_TO_CONFORM_PROTOCOL"

    var name: String {
        return self.rawValue
    }

    var description: String {
        switch self {
        case .denied:
            return "User has explicitly denied authorization"
        case .notDetermined:
            return "User has not yet made a choice"
        case .restricted:
            return "Host app is not authorized to use location services"
        case .failedToConformToProtocol:
            return "Host app failed to implement required interface"
        }
    }
}

/// Enumeration that is used to differentiate the Custom permission errors
public enum MASDKCustomPermissionError: String, MiniAppErrorProtocol {

    /// Unknown Error
    case unknownError = "UKNOWN_ERROR"

    /// Host app failed to implement required interface
    case failedToConformToProtocol = "FAILED_TO_CONFORM_PROTOCOL"

    /// Invalid Custom Permission request from Mini app
    case invalidCustomPermissionRequest

    /// Invalid list of Custom Permission requested from Mini app
    case invalidCustomPermissionsList

    /// User denied the Custom Permission
    case userDenied

    /// Invalid scope request for the Custom Permission
    case outOfScope

    /// User name Customer permission denied error
    case userNamePermissionError

    /// Profile Photo Customer permission denied error
    case profilePhotoPermissionError

    /// Access Token Customer permission denied error
    case accessTokenPermissionError

    /// Contacts Customer permission denied error
    case contactsPermissionError

    /// Points Customer permission denied error
    case pointsPermissionError

    /// Location Customer permission denied error
    case locationPermissionError

    public var name: String {
        return self.rawValue
    }

    /// Detailed Description for every MASDKCustomPermissionError
    public var description: String {
        switch self {
        case .unknownError:
            return "Unknown error occurred"
        case .failedToConformToProtocol:
            return "Host app failed to implement required interface"
        case .invalidCustomPermissionRequest:
            return "Error in Custom Permission Request, please make sure the Custom permissions are passed in []"
        case .invalidCustomPermissionsList:
            return "Error in list of Custom permissions that is passed, please check whether valid permission associated with name "
        case .userDenied:
            return "User denied to share the detail"
        case .outOfScope:
            return "Invalid scope request for the Custom Permission"
        case .userNamePermissionError:
            return "Cannot get user name: Permission has not been accepted yet for getting user name."
        case .profilePhotoPermissionError:
            return "Cannot get profile photo: Permission has not been accepted yet for getting profile photo."
        case .accessTokenPermissionError:
            return "Cannot get access token: Permission has not been accepted yet for getting access token."
        case .contactsPermissionError:
            return "Cannot get contacts: Permission has not been accepted yet for getting contacts."
        case .pointsPermissionError:
            return "Cannot get points: Permission has not been accepted yet for getting points."
        case .locationPermissionError:
            return "Cannot get location: Permission has not been accepted yet for getting location."
        }
    }
}

/// Enumeration that is used to return  Access Token error
public enum MASDKAccessTokenError: Error, MiniAppErrorProtocol {

    /// Host app failed to implement required interface
    case failedToConformToProtocol

    /// Requested Audience is not supported
    case audienceNotSupportedError

    /// Requested Scope is not supported
    case scopesNotSupportedError

    /// Authorization failed and the reason will be shared by the host app
    case authorizationFailureError(description: String)

    /// Unknown/Custom error
    case error(description: String)

    /// Detailed Description for every MASDKAccessTokenError
    public var description: String {
        switch self {
        case .failedToConformToProtocol:
            return MASDKLocale.localize(.failedToConformToProtocol)
        case .audienceNotSupportedError, .scopesNotSupportedError:
            return ""
        case .authorizationFailureError(let description):
            return description
        case .error(let description):
            return description
        }
    }

    /// Title of the error
    public var name: String {
        switch self {
        case .failedToConformToProtocol:
            return "FailedToConformToProtocol"
        case .audienceNotSupportedError:
            return "AudienceNotSupportedError"
        case .scopesNotSupportedError:
            return "ScopesNotSupportedError"
        case .authorizationFailureError:
            return "AuthorizationFailureError"
        case .error:
            return ""
        }
    }
}

/// Enumeration that is used to return Points error
public enum MASDKPointError: Error, MiniAppErrorProtocol {

    /// Host app failed to implement required interface
    case failedToConformToProtocol
    case error(description: String)

    /// Detailed Description
    public var description: String {
        switch self {
        case .failedToConformToProtocol:
            return MASDKLocale.localize(.failedToConformToProtocol)
        case .error(let description):
            return description
        }
    }

    /// Title of the error
    public var name: String {
        switch self {
        case .failedToConformToProtocol:
            return "FailedToConformToProtocol"
        case .error:
            return ""
        }
    }
}

enum MAJSNaviGeolocationError: Error {
    case userDenied
    case devicePermissionDenied

    var code: Int {
        switch self {
        case .userDenied:
        return 1
        case .devicePermissionDenied:
        return 2
        }
    }

    var message: String {
        switch self {
        case .userDenied:
        return "User denied Geolocation"
        case .devicePermissionDenied:
        return "application does not have sufficient geolocation permissions."
        }
    }
}

/// Enumeration that is used to return DownloadFile error
public enum MASDKDownloadFileError: Error {

    /// Host app failed to implement required interface
    ///
    case failedToConformToProtocol
    case invalidUrl
    case downloadFailed(code: Int?, reason: String)
    case downloadHttpError(code: Int, reason: String)
    case saveTemporarilyFailed
    case error(description: String)

    /// Detailed Description
    public var description: String {
        switch self {
        case .failedToConformToProtocol:
            return MASDKLocale.localize(.failedToConformToProtocol)
        case .invalidUrl:
            return MASDKLocale.localize(.invalidUrl)
        case .downloadFailed(_, let reason):
            return  "\(reason); \(MASDKLocale.localize(.downloadFailed))"
        case .downloadHttpError(_, let reason):
            return "\(reason); \(MASDKLocale.localize(.downloadFailed))"
        case .saveTemporarilyFailed:
            return MASDKLocale.localize(.unknownError)
        case .error(let description):
            return description
        }
    }

    /// Status code in the case of HTTP error
    public var code: Int? {
        switch self {
        case .downloadFailed(let code, _):
            return code
        case .downloadHttpError(let code, _):
            return code
        default:
            return nil
        }
    }

    /// Title of the error
    public var name: String {
        switch self {
        case .failedToConformToProtocol:
            return "FailedToConformToProtocol"
        case .invalidUrl:
            return "InvalidUrlError"
        case .downloadFailed:
            return "DownloadFailedError"
        case .downloadHttpError:
            return "DownloadHttpError"
        case .saveTemporarilyFailed:
            return "SaveFailureError"
        case .error:
            return ""
        }
    }
}

public enum UniversalBridgeError: Error, MiniAppErrorProtocol {
    /// Host app failed to implement required interface
    case failedToConformToProtocol
    case error(description: String)

    /// Title of the error
    public var name: String {
        switch self {
        case .failedToConformToProtocol:
            return "FAILED_TO_CONFORM_PROTOCOL"
        case .error(let name):
            return name
        }
    }

    /// Detailed Description
    public var description: String {
        switch self {
        case .failedToConformToProtocol:
            return MASDKLocale.localize(.failedToConformToProtocol)
        case .error(let description):
            return description
        }
    }
}
