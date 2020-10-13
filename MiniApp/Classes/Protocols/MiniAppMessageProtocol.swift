/**
Public Protocol that will be used by the Mini App to communicate
 with the Native implementation
*/
public protocol MiniAppMessageProtocol: MiniAppUserInfoDelegate {

    /// Interface that should be implemented to return alphanumeric string that uniquely identifies a device.
    func getUniqueId() -> String

    /// Interface that should be implemented in the host app that handles the code to request any permission and the
    /// result (allowed/denied) should be returned.
    func requestPermission(permissionType: MiniAppPermissionType, completionHandler: @escaping (Result<MASDKPermissionResponse, MASDKPermissionError>) -> Void)

    /// Interface that should be implemented in the host app to handle the Custom Permissions.
    /// Host app is responsible to display the alert/dialog with the [MiniAppCustomPermissionType] permissions to the user and the result should be returned back to the SDK
    func requestCustomPermissions(permissions: [MASDKCustomPermissionModel], completionHandler: @escaping (Result<[MASDKCustomPermissionModel], MASDKCustomPermissionError>) -> Void)

    /// Interface that is used to share the content from the Mini app
    func shareContent(info: MiniAppShareContent, completionHandler: @escaping (Result<MASDKProtocolResponse, Error>) -> Void)
}

/**
 Public Protocol that will be used by the Mini App to communicate
 with the Native implementation for User profile related retrieval
*/
public protocol MiniAppUserInfoDelegate: class {
    /// Interface that is used to retrieve the user name from the User Profile
    func getUserName() -> String?

    /// Interface that is used to retrieve the Image URI
    func getProfilePhoto() -> String?
}

public enum MASDKProtocolResponse: String {
    case success = "SUCCESS"
}

public enum MASDKPermissionResponse: String {
    case allowed = "ALLOWED"
}

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

public enum MASDKCustomPermissionError: String, MiniAppErrorProtocol {
    case unknownError = "UKNOWN_ERROR"
    case failedToConformToProtocol = "FAILED_TO_CONFORM_PROTOCOL"
    case invalidCustomPermissionRequest
    case invalidCustomPermissionsList
    case userDenied

    var name: String {
        return self.rawValue
    }

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
        }
    }
}
