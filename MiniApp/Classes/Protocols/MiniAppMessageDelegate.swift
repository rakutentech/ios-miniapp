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
    func requestPermission(permissionType: MiniAppPermissionType, completionHandler: @escaping (Result<MASDKPermissionResponse, MASDKPermissionError>) -> Void)

    /// Interface that should be implemented in the host app to handle the Custom Permissions.
    /// Host app is responsible to display the alert/dialog with the [MiniAppCustomPermissionType] permissions to the user and the result should be returned back to the SDK
    func requestCustomPermissions(permissions: [MASDKCustomPermissionModel], completionHandler: @escaping (Result<[MASDKCustomPermissionModel], MASDKCustomPermissionError>) -> Void)
}

public extension MiniAppMessageDelegate {
    func requestCustomPermissions(
        permissions: [MASDKCustomPermissionModel],
        completionHandler: @escaping (
        Result<[MASDKCustomPermissionModel], MASDKCustomPermissionError>) -> Void) {
//        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomPermissionsTableViewController") as? CustomPermissionsTableViewController {
//            viewController.customPermissionHandlerObj = completionHandler
//            viewController.permissionsRequestList = permissions
//            viewController.miniAppTitle = self.currentMiniAppTitle ?? "MiniApp"
//            let navController = UINavigationController(rootViewController: viewController)
//            navController.modalPresentationStyle = .fullScreen
//            UIViewController.topViewController()?.present(navController, animated: true, completion: nil)
//        }
        
        let podBundle: Bundle = Bundle(for: MiniApp.self)
        let customPermissionRequestController = CustomPermissionsRequestViewController(nibName: "CustomPermissionsRequestViewController", bundle: podBundle)
        customPermissionRequestController.customPermissionHandlerObj = completionHandler
        customPermissionRequestController.permissionsRequestList = permissions
//        customPermissionRequestController.miniAppTitle = self.currentMiniAppTitle ?? "MiniApp"

        customPermissionRequestController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        customPermissionRequestController.modalPresentationStyle = .overFullScreen
        UIViewController.topViewController()?.present(customPermissionRequestController,
            animated: true,
            completion: nil)

    }
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
//
//extension UIViewController {
//    static func loadFromNib() -> Self {
//        func instantiateFromNib<T: UIViewController>() -> T {
//            let podBundle: Bundle = Bundle(for: MiniApp.self)
//
//            return T.init(nibName: String(describing: T.self), bundle: podBundle)
//        }
//        return instantiateFromNib()
//    }
//}
