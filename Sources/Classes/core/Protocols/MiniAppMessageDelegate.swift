import Foundation
import UIKit

/**
Public Protocol that will be used by the Mini App to communicate
 with the Native implementation
*/
public protocol MiniAppMessageDelegate: MiniAppUserInfoDelegate, MiniAppShareContentDelegate, ChatMessageBridgeDelegate, UniversalBridgeDelegate, MAAnalyticsDelegate {

    /// Interface that should be implemented to return alphanumeric string that uniquely identifies a device.
    @available(*, deprecated, renamed: "getMessagingUniqueId(completionHandler:)")
    func getUniqueId(completionHandler: @escaping (Result<String?, MASDKError>) -> Void)

    /// Interface that should be implemented to return alphanumeric string that uniquely identifies a device assembled as message unique id
    func getMessagingUniqueId(completionHandler: @escaping (Result<String?, MASDKError>) -> Void)

    /// Interface that should be implemented to return alphanumeric string that uniquely identifies a device assembled as mauid
    func getMauid(completionHandler: @escaping (Result<String?, MASDKError>) -> Void)

    /// Interface that should be implemented in the host app that handles the code to request any permission and the
    /// result (allowed/denied) should be returned.
    func requestDevicePermission(permissionType: MiniAppDevicePermissionType, completionHandler: @escaping (Result<MASDKPermissionResponse, MASDKPermissionError>) -> Void)

    /// Optional Interface that can be implemented in the host app to handle the Custom Permissions.
    /// SDK will open its default UI for prompting Custom Permissions request if this protocol interface is not overridden
    func requestCustomPermissions(permissions: [MASDKCustomPermissionModel],
                                  miniAppTitle: String,
                                  completionHandler: @escaping (Result<[MASDKCustomPermissionModel], MASDKCustomPermissionError>) -> Void)

    /// Optional Interface that can be implemented in the host app to retrieve MAHostEnvironmentInfo
    var getEnvironmentInfo: (() -> (MAHostEnvironmentInfo))? {get}

    /// Interface that is used to download files
    func downloadFile(fileName: String, url: String, headers: DownloadHeaders, completionHandler: @escaping (Result<String, MASDKDownloadFileError>) -> Void)

    /// Interface to recieve the close command from the MiniApp
    func closeMiniApp(withConfirmation: Bool, completionHandler: @escaping (Result<Bool, MiniAppJavaScriptError>) -> Void)

    /// Interface to get the host app theme colors
    func getHostAppThemeColors(completionHandler: @escaping (Result<HostAppThemeColors?, MiniAppJavaScriptError>) -> Void)

    /// Interface to get if the Device is in Dark mode
    func isDarkMode(completionHandler: @escaping (Result<Bool, MiniAppJavaScriptError>) -> Void)

}

public extension MiniAppMessageDelegate {

    func requestCustomPermissions(
        permissions: [MASDKCustomPermissionModel], miniAppTitle: String,
        completionHandler: @escaping (
            Result<[MASDKCustomPermissionModel], MASDKCustomPermissionError>) -> Void) {
        let podBundle: Bundle = Bundle.miniAppSDKBundle
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

    @available(*, deprecated, renamed: "getMessagingUniqueId(completionHandler:)")
    func getUniqueId(completionHandler: @escaping (Result<String?, MASDKError>) -> Void) {
        completionHandler(.failure(.failedToConformToProtocol))
    }

    func getMessagingUniqueId(completionHandler: @escaping (Result<String?, MASDKError>) -> Void) {
        completionHandler(.failure(.failedToConformToProtocol))
    }

    func getMauid(completionHandler: @escaping (Result<String?, MASDKError>) -> Void) {
        completionHandler(.failure(.failedToConformToProtocol))
    }

    var getEnvironmentInfo: (() -> (MAHostEnvironmentInfo))? {
        return { () -> (() -> (MAHostEnvironmentInfo))? in
            return { MAHostEnvironmentInfo(hostLocale: "miniapp.sdk.ios.locale".localizedString()) }
        }()
    }

    func downloadFile(fileName: String, url: String, headers: DownloadHeaders, completionHandler: @escaping (Result<String, MASDKError>) -> Void) {
        completionHandler(.failure(.failedToConformToProtocol))
    }

    func sendJsonToHostApp(info: String, completionHandler: @escaping (Result<MASDKProtocolResponse, UniversalBridgeError>) -> Void) {
        completionHandler(.failure(.failedToConformToProtocol))
    }

    func closeMiniApp(withConfirmation: Bool, completionHandler: @escaping (Result<Bool, MiniAppJavaScriptError>) -> Void) {
        completionHandler(.failure(.failedToConformToProtocol))
    }

    func getHostAppThemeColors(completionHandler: @escaping (Result<HostAppThemeColors?, MiniAppJavaScriptError>) -> Void) {
        completionHandler(.failure(.failedToConformToProtocol))
    }

    func isDarkMode(completionHandler: @escaping (Result<Bool, MiniAppJavaScriptError>) -> Void) {
        completionHandler(.failure(.failedToConformToProtocol))
    }

    func didReceiveMAAnalytics(analyticsInfo: MAAnalytics, completionHandler: @escaping (Result<MASDKProtocolResponse, MAAnalyticsError>) -> Void) {
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

public class MAHostEnvironmentInfo: Codable {
    let platformVersion: String
    let hostVersion: String
    let sdkVersion: String
    let hostLocale: String

    public init(platformVersion: String, hostVersion: String, sdkVersion: String, hostLocale: String) {
        self.platformVersion = platformVersion
        self.hostVersion = hostVersion
        self.sdkVersion = sdkVersion
        if hostLocale.isValidLocale {
            self.hostLocale = hostLocale
        } else {
            self.hostLocale = "miniapp.sdk.ios.locale".localizedString()
        }
    }

    public convenience init(hostLocale: String) {
        let environment = Environment(bundle: Bundle.main)
        self.init(
            platformVersion: UIDevice.current.systemVersion,
            hostVersion: environment.appVersion,
            sdkVersion: environment.sdkVersion?.description ?? "-",
            hostLocale: hostLocale
        )
    }
}

// Used for download files headers
public typealias DownloadHeaders = [String: String]

// Model class used for sending the Host App theme colors to miniapp
public class HostAppThemeColors: Codable {
    public let primaryColor: String
    public let secondaryColor: String

    public init(primaryColor: String, secondaryColor: String) {
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
    }
}
