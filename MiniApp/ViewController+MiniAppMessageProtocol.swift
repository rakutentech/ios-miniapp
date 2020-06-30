import MiniApp
import CoreLocation

extension ViewController: MiniAppMessageProtocol, CLLocationManagerDelegate {
    typealias PermissionCompletionHandler = (((Result<String, Error>)) -> Void)

    func requestPermission(completionHandler: @escaping (Result<String, Error>) -> Void) {
        locationManager.delegate = self
        let locStatus = CLLocationManager.authorizationStatus()
        permissionHandlerObj = completionHandler
        switch locStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied:
            displayLocationDisabledAlert()
            completionHandler(.failure(MiniAppPermissionResult.denied))
        case .authorizedAlways, .authorizedWhenInUse:
            completionHandler(.success("allowed"))
        case .restricted:
            completionHandler(.failure(MiniAppPermissionResult.restricted))
        @unknown default:
        break
        }
    }

    func getUniqueId() -> String {
        guard let deviceId = UIDevice.current.identifierForVendor?.uuidString else {
            return ""
        }
        return deviceId
    }

    func displayLocationDisabledAlert() {
        let alert = UIAlertController(title: "Location Services are disabled", message: "Please enable Location Services in your Settings", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied:
            permissionHandlerObj?(.failure(MiniAppPermissionResult.denied))
        case .authorizedWhenInUse, .authorizedAlways:
            permissionHandlerObj?(.success("allowed"))
        case .notDetermined:
            permissionHandlerObj?(.failure(MiniAppPermissionResult.notDetermined))
        case .restricted:
            permissionHandlerObj?(.failure(MiniAppPermissionResult.restricted))
        @unknown default:
        break
        }
    }
}
