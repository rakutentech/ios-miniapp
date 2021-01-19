@available(*, deprecated, message: "protocol renamed to MiniAppMessageDelegate")
public typealias MiniAppMessageProtocol = MiniAppMessageDelegate

/**
Public Protocol that will be used by the Mini App to communicate
 with the Native implementation
*/
public protocol MiniAppMessageDelegate: MiniAppUserInfoDelegate, MiniAppShareContentDelegate {

    /// Interface that should be implemented to return alphanumeric string that uniquely identifies a device.
    func getUniqueId() -> String

    /// Interface that should be implemented in the host app that handles the code to request any permission and the
    /// result (allowed/denied) should be returned.
    func requestDevicePermission(permissionType: MiniAppDevicePermissionType, completionHandler: @escaping (Result<MASDKPermissionResponse, MASDKPermissionError>) -> Void)

    /// Interface that should be implemented in the host app that handles the code to request any permission and the
    /// result (allowed/denied) should be returned.
    @available(*, deprecated,
        message: "Since version 2.8.0, this method is deprecated",
        renamed: "requestDevicePermission(permissionType:completionHandler:)")
    func requestPermission(permissionType: MiniAppPermissionType, completionHandler: @escaping (Result<MASDKPermissionResponse, MASDKPermissionError>) -> Void)

    /// Optional Interface that can be implemented in the host app to handle the Custom Permissions.
    /// SDK will open its default UI for prompting Custom Permissions request if this protocol interface is not overridden
    func requestCustomPermissions(permissions: [MASDKCustomPermissionModel],
                                  miniAppTitle: String,
                                  completionHandler: @escaping (Result<[MASDKCustomPermissionModel], MASDKCustomPermissionError>) -> Void)

    /// Interface that should be implemented in the host app to handle the Custom Permissions.
    /// Host app is responsible to display the alert/dialog with the [MiniAppCustomPermissionType] permissions to the user and the result should be returned back to the SDK
    @available(*, deprecated,
        message: "Since version 2.3.0, this method is deprecated",
        renamed: "requestCustomPermissions(permissions:miniAppTitle:completionHandler:)")
    func requestCustomPermissions(permissions: [MASDKCustomPermissionModel],
                                  completionHandler: @escaping (Result<[MASDKCustomPermissionModel], MASDKCustomPermissionError>) -> Void)
}

public extension MiniAppMessageDelegate {

    func requestCustomPermissions(
        permissions: [MASDKCustomPermissionModel], miniAppTitle: String,
        completionHandler: @escaping (
            Result<[MASDKCustomPermissionModel], MASDKCustomPermissionError>) -> Void) {
        let podBundle: Bundle = Bundle(for: MiniApp.self)
        let customPermissionRequestController = CustomPermissionsRequestViewController(nibName: "CustomPermissionsRequestViewController", bundle: podBundle)
        customPermissionRequestController.customPermissionHandlerObj = completionHandler
        customPermissionRequestController.permissionsRequestList = permissions
        customPermissionRequestController.miniAppTitle = miniAppTitle
        customPermissionRequestController.modalPresentationStyle = .overFullScreen
        UIViewController.topViewController()?.present(customPermissionRequestController,
            animated: true,
            completion: nil)
    }

    func requestCustomPermissions(
        permissions: [MASDKCustomPermissionModel], completionHandler: @escaping (
            Result<[MASDKCustomPermissionModel], MASDKCustomPermissionError>) -> Void) {
        self.requestCustomPermissions(permissions: permissions, miniAppTitle: "Mini App", completionHandler: completionHandler)
    }

    func requestPermission(permissionType: MiniAppDevicePermissionType, completionHandler: @escaping (Result<MASDKPermissionResponse, MASDKPermissionError>) -> Void) {
        requestDevicePermission(permissionType: permissionType, completionHandler: completionHandler)
    }

    func requestDevicePermission(permissionType: MiniAppDevicePermissionType, completionHandler: @escaping (Result<MASDKPermissionResponse, MASDKPermissionError>) -> Void) {
        completionHandler(.failure(.failedToConformToProtocol))
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
        }
    }
}
