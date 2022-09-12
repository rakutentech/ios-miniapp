import Foundation
import MiniApp
import CoreLocation

class MiniAppViewDelegator: NSObject, MiniAppMessageDelegate {
    
    let locationManager = LocationManager()
    var permissionHandlerObj: PermissionCompletionHandler?

    var miniAppId: String
    var miniAppVersion: String?

    var onSendMessage: (() -> Void)?

    init(miniAppId: String = "", miniAppVersion: String? = nil) {
        self.miniAppId = miniAppId
        self.miniAppVersion = miniAppVersion
    }

    func getUniqueId(completionHandler: @escaping (Result<String?, MASDKError>) -> Void) {
        completionHandler(.success("MAUID-\(miniAppId.prefix(8))-\((miniAppVersion ?? "").prefix(8))"))
    }

    func downloadFile(fileName: String, url: String, headers: DownloadHeaders, completionHandler: @escaping (Result<String, MASDKDownloadFileError>) -> Void) {
        //
    }

    func sendMessageToContact(_ message: MessageToContact, completionHandler: @escaping (Result<String?, MASDKError>) -> Void) {
        onSendMessage?()
    }

    func sendMessageToContactId(_ contactId: String, message: MessageToContact, completionHandler: @escaping (Result<String?, MASDKError>) -> Void) {
        onSendMessage?()
    }

    func sendMessageToMultipleContacts(_ message: MessageToContact, completionHandler: @escaping (Result<[String]?, MASDKError>) -> Void) {
        onSendMessage?()
    }

    func getUserName(completionHandler: @escaping (Result<String?, MASDKError>) -> Void) {
        completionHandler(.success(getProfileSettings()?.displayName))
    }

    func getProfilePhoto(completionHandler: @escaping (Result<String?, MASDKError>) -> Void) {
        completionHandler(.success(getProfileSettings()?.profileImageURI))
    }

    func getContacts(completionHandler: @escaping (Result<[MAContact]?, MASDKError>) -> Void) {
        completionHandler(.success(getContactList()))
        return
    }

    func getPoints(completionHandler: @escaping (Result<MAPoints, MASDKPointError>) -> Void) {
        if let points = getUserPoints() {
            completionHandler(.success(
                MAPoints(
                    standard: points.standardPoints ?? 0,
                    term: points.termPoints ?? 0,
                    cash: points.cashPoints ?? 0
                )
            ))
        } else {
            completionHandler(.success(MAPoints(standard: 0, term: 0, cash: 0)))
        }
    }

    func requestCustomPermissions(permissions: [MASDKCustomPermissionModel], miniAppTitle: String, completionHandler: @escaping (Result<[MASDKCustomPermissionModel], MASDKCustomPermissionError>) -> Void) {
        completionHandler(.failure(.userDenied))
    }

    func requestDevicePermission(permissionType: MiniAppDevicePermissionType, completionHandler: @escaping (Result<MASDKPermissionResponse, MASDKPermissionError>) -> Void) {
        switch permissionType {
        case .location:
            let locStatus = locationManager.authorizationStatus
            permissionHandlerObj = completionHandler
            switch locStatus {
            case .notDetermined:
                locationManager.requestPermission()
            case .denied:
                //displayLocationDisabledAlert()
                completionHandler(.failure(.denied))
            case .authorizedAlways, .authorizedWhenInUse:
                completionHandler(.success(.allowed))
            case .restricted:
                completionHandler(.failure(.restricted))
            @unknown default:
            break
            }
        }
    }

    func getAccessToken(miniAppId: String, scopes: MASDKAccessTokenScopes, completionHandler: @escaping (Result<MATokenInfo, MASDKAccessTokenError>) -> Void) {
        let store = MiniAppStore.shared
        let errorBehavior = store.accessTokenErrorBehavior
        if
            !errorBehavior.isEmpty,
            let errorMode = MiniAppSettingsAccessTokenView.ErrorBehavior(rawValue: errorBehavior)
        {
            let message = store.accessTokenErrorMessage
            switch errorMode {
            case .authorization:
                let desc = "authorizationFailureError" + ( (!message.isEmpty) ? ": " + message : "" )
                return completionHandler(
                    .failure(.authorizationFailureError(description: desc))
                )
            default:
                let desc = "Other error" + ( (!message.isEmpty) ? ": " + message : "" )
                return completionHandler(
                    .failure(.error(description: desc))
                )
            }
        }

        if let info = getTokenInfo() {
            completionHandler(
                .success(
                    MATokenInfo(
                        accessToken: info.tokenString,
                        expirationDate: info.expiryDate,
                        scopes: scopes
                    )
                )
            )
        } else {
            completionHandler(.failure(.failedToConformToProtocol))
        }
    }

}

extension MiniAppViewDelegator: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied:
            permissionHandlerObj?(.failure(.denied))
        case .authorizedWhenInUse, .authorizedAlways:
            permissionHandlerObj?(.success(.allowed))
        case .notDetermined:
            permissionHandlerObj?(.failure(.notDetermined))
        case .restricted:
            permissionHandlerObj?(.failure(.restricted))
        @unknown default:
        break
        }
    }
}
