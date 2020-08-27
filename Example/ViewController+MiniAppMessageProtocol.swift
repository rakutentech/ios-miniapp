import MiniApp
import CoreLocation

extension ViewController: MiniAppMessageProtocol, CLLocationManagerDelegate {

    typealias PermissionCompletionHandler = (((Result<String, Error>)) -> Void)

    func requestPermission(permissionType: MiniAppPermissionType, completionHandler: @escaping (Result<String, Error>) -> Void) {
        switch permissionType {
        case .location:
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
    }

    func requestCustomPermissions(permissions: [MASDKCustomPermissionModel], completionHandler: @escaping (Result<[MASDKCustomPermissionModel], Error>) -> Void) {
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomPermissionsTableViewController") as? CustomPermissionsTableViewController {
            viewController.customPermissionHandlerObj = completionHandler
            viewController.permissionsRequestList = permissions
            viewController.miniAppTitle = self.currentMiniAppTitle ?? "MiniApp"
            let navController = UINavigationController(rootViewController: viewController)
            navController.modalPresentationStyle = .fullScreen
            UIViewController.topViewController()?.present(navController, animated: true, completion: nil)
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
