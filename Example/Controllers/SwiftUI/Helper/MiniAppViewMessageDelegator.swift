import Foundation
import MiniApp
import CoreLocation
import UIKit

class MiniAppViewMessageDelegator: NSObject, MiniAppMessageDelegate {

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
                // displayLocationDisabledAlert()
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

    func getHostEnvironmentInfo(completionHandler: @escaping (Result<MAHostEnvironmentInfo, MASDKError>) -> Void) {
        let locale = NSLocalizedString("miniapp.sdk.ios.locale", comment: "")
        let info = MAHostEnvironmentInfo(hostLocale: locale)
        completionHandler(.success(info))
    }

    var getEnvironmentInfo: (() -> (MAHostEnvironmentInfo))? {
        let locale = NSLocalizedString("miniapp.sdk.ios.locale", comment: "")
        let info = MAHostEnvironmentInfo(hostLocale: locale)
        return { return info }
    }

    // MARK: - Download
    func downloadFile(fileName: String, url: String, headers: DownloadHeaders, completionHandler: @escaping (Result<String, MASDKDownloadFileError>) -> Void) {
        guard let downloadUrl = URL(string: url) else {
            completionHandler(.failure(.invalidUrl))
            return
        }
        let topViewController = UIApplication.shared.keyWindow?.topController()
        download(url: downloadUrl.absoluteString, headers: headers) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    guard
                        let savedUrl = self.saveTemporaryFile(data: data,
                                                              resourceName: fileName.stringByDeletingPathExtension,
                                                              fileExtension: fileName.pathExtension)
                    else {
                        completionHandler(.failure(MASDKDownloadFileError.saveTemporarilyFailed))
                        return
                    }
                    let activityVc = MiniAppActivityController(activityItems: [savedUrl], applicationActivities: nil)
                    topViewController?.present(activityVc, animated: true, completion: nil)
                    completionHandler(.success(fileName))
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
        }
    }
}

extension MiniAppViewMessageDelegator {
    func download(url: String, headers: DownloadHeaders, completion: ((Result<Data, MASDKDownloadFileError>) -> Void)? = nil) {
        if Base64UriHelper.isBase64String(text: url) {
            guard
                let data = Base64UriHelper.decodeBase64String(text: url)
            else {
                completion?(.failure(MASDKDownloadFileError.invalidUrl))
                return
            }

            completion?(.success(data))
        } else {
            guard
                let url = URL(string: url)
            else {
                completion?(.failure(MASDKDownloadFileError.invalidUrl))
                return
            }
            let session = URLSession.shared
            var request = URLRequest(url: url)
            headers.forEach({ request.addValue($0.value, forHTTPHeaderField: $0.key) })
            let task = session.downloadTask(with: request) { (tempFileUrl, response, error) in
                if let error = error {
                    completion?(.failure(MASDKDownloadFileError.downloadFailed(code: -1, reason: error.localizedDescription)))
                    return
                }
                guard
                    let statusCode = (response as? HTTPURLResponse)?.statusCode
                else {
                    completion?(.failure(MASDKDownloadFileError.downloadFailed(code: -1, reason: "no status code")))
                    return
                }
                guard
                    statusCode >= 200 && statusCode <= 300
                else {
                    let reason = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                    completion?(.failure(MASDKDownloadFileError.downloadHttpError(code: statusCode, reason: reason)))
                    return
                }
                guard
                    let tempFileUrl = tempFileUrl,
                        let data = try? Data(contentsOf: tempFileUrl)
                else {
                    completion?(.failure(MASDKDownloadFileError.downloadFailed(code: -1, reason: "could not load local data")))
                    return
                }

                completion?(.success(data))
            }
            task.resume()
        }
    }

    func saveTemporaryFile(data: Data, resourceName: String, fileExtension: String) -> URL? {
        let tempDirectoryURL = URL.init(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let targetURL = tempDirectoryURL.appendingPathComponent("\(resourceName).\(fileExtension)")
        do {
            try data.write(to: targetURL, options: .atomic)
            return targetURL
        } catch let error {
            print("Unable to copy file: \(error)")
        }
        return nil
    }
}

extension MiniAppViewMessageDelegator: CLLocationManagerDelegate {
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
