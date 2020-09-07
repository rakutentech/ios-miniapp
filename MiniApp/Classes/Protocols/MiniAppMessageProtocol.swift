/**
Public Protocol that will be used by the Mini App to communicate
 with the Native implementation
*/
public protocol MiniAppMessageProtocol: class {

    /// Interface that should be implemented to return alphanumeric string that uniquely identifies a device.
    func getUniqueId() -> String

    /// Interface that should be implemented in the host app that handles the code to request any permission and the
    /// result (allowed/denied) should be returned.
    func requestPermission(permissionType: MiniAppPermissionType, completionHandler: @escaping (Result<String, Error>) -> Void)

    /// Interface that should be implemented in the host app to handle the Custom Permissions.
    /// Host app is responsible to display the alert/dialog with the [MiniAppCustomPermissionType] permissions to the user and the result should be returned back to the SDK
    func requestCustomPermissions(permissions: [MASDKCustomPermissionModel], completionHandler: @escaping (Result<[MASDKCustomPermissionModel], Error>) -> Void)
}
