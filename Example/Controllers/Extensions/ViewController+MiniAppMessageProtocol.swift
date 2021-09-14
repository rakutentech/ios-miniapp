import MiniApp
import CoreLocation

extension ViewController: MiniAppMessageDelegate, CLLocationManagerDelegate {
    typealias PermissionCompletionHandler = (((Result<MASDKPermissionResponse, MASDKPermissionError>)) -> Void)

    func requestDevicePermission(permissionType: MiniAppDevicePermissionType, completionHandler: @escaping (Result<MASDKPermissionResponse, MASDKPermissionError>) -> Void) {
        switch permissionType {
        case .location:
            let locStatus = CLLocationManager.authorizationStatus()
            permissionHandlerObj = completionHandler
            switch locStatus {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .denied:
                displayLocationDisabledAlert()
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

    func getUniqueId(completionHandler: @escaping (Result<String?, MASDKError>) -> Void) {
        guard let deviceId = UIDevice.current.identifierForVendor?.uuidString else {
            return completionHandler(.failure(.unknownError(domain: "Unknown Error", code: 1, description: "Failed to retrieve UniqueID")))
        }
        completionHandler(.success(deviceId))
    }

    func displayLocationDisabledAlert() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let alert = UIAlertController(title: "Location Services are disabled", message: "Please enable Location Services in your Settings", preferredStyle: .alert)
            let okAction = UIAlertAction(title: MASDKLocale.localize(.ok), style: .default, handler: nil)
            alert.addAction(okAction)
            UIViewController.topViewController()?.present(alert, animated: true, completion: nil)
        }
    }
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

    func getHostEnvironmentInfo(completionHandler: @escaping (Result<MAHostEnvironmentInfo, MASDKError>) -> Void) {
        completionHandler(
            .success(MAHostEnvironmentInfo(
                platform: "iOS",
                platformVersion: "5.0.0",
                hostVersion: "2.7.0",
                sdkVersion: "3.6.0"
            ))
        )
    }
}
