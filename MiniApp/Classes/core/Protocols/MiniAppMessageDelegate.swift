/**
Public Protocol that will be used by the Mini App to communicate
 with the Native implementation
*/
public protocol MiniAppMessageDelegate: MiniAppUserInfoDelegate, MiniAppShareContentDelegate, ChatMessageBridgeDelegate {

    /// Interface that should be implemented to return alphanumeric string that uniquely identifies a device.
    func getUniqueId(completionHandler: @escaping (Result<String?, MASDKError>) -> Void)

    @available(*, deprecated,
        renamed: "getUniqueId(completionHandler:)")
    func getUniqueId() -> String?

    /// Interface that should be implemented in the host app that handles the code to request any permission and the
    /// result (allowed/denied) should be returned.
    func requestDevicePermission(permissionType: MiniAppDevicePermissionType, completionHandler: @escaping (Result<MASDKPermissionResponse, MASDKPermissionError>) -> Void)

    /// Optional Interface that can be implemented in the host app to handle the Custom Permissions.
    /// SDK will open its default UI for prompting Custom Permissions request if this protocol interface is not overridden
    func requestCustomPermissions(permissions: [MASDKCustomPermissionModel],
                                  miniAppTitle: String,
                                  completionHandler: @escaping (Result<[MASDKCustomPermissionModel], MASDKCustomPermissionError>) -> Void)

}

public extension MiniAppMessageDelegate {

    func requestCustomPermissions(
        permissions: [MASDKCustomPermissionModel], miniAppTitle: String,
        completionHandler: @escaping (
            Result<[MASDKCustomPermissionModel], MASDKCustomPermissionError>) -> Void) {
        let podBundle: Bundle = Bundle.miniAppSDKBundle()
        let customPermissionRequestController = CustomPermissionsRequestViewController(nibName: "CustomPermissionsRequestViewController", bundle: podBundle)
        customPermissionRequestController.customPermissionHandlerObj = completionHandler
        customPermissionRequestController.permissionsRequestList = permissions
        customPermissionRequestController.miniAppTitle = miniAppTitle
        customPermissionRequestController.modalPresentationStyle = .overFullScreen
        UIViewController.topViewController()?.present(customPermissionRequestController,
            animated: true,
            completion: nil)
    }

    func requestDevicePermission(permissionType: MiniAppDevicePermissionType, completionHandler: @escaping (Result<MASDKPermissionResponse, MASDKPermissionError>) -> Void) {
        completionHandler(.failure(.failedToConformToProtocol))
    }

    func getUniqueId(completionHandler: @escaping (Result<String?, MASDKError>) -> Void) {
        completionHandler(.failure(.unknownError(domain: MASDKLocale.localize(.hostAppError), code: 1, description: MASDKLocale.localize(.failedToConformToProtocol))))
    }

    @available(*, deprecated,
        renamed: "getUniqueId(completionHandler:)")
    func getUniqueId() -> String? {
        let semaphore = DispatchSemaphore(value: 0)
        var uniqueId: String?
        getUniqueId { result in
            switch result {
            case .success(let id):
                uniqueId = id
            default:
                uniqueId = nil
            }
            semaphore.signal()
        }
        semaphore.wait()
        return uniqueId
    }
}

public enum MASDKProtocolResponse: String {
    case success = "SUCCESS"
}

/// Enumeration that is used to differentiate the response from the User
public enum MASDKPermissionResponse: String {
    /// User allowed the Device Permission
    case allowed = "ALLOWED"
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

    var name: String {
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
        case .audienceNotSupportedError:
            return "The value passed for 'audience' is not supported."
        case .scopesNotSupportedError:
            return "The value passed for 'scopes' is not supported."
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
