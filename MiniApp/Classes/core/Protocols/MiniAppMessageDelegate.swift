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
