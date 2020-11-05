import UIKit
import CoreLocation

class CustomPermissionsRequestViewController: UIViewController {

    @IBOutlet weak var footerLabel: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!

    typealias CustomPermissionsCompletionHandler = (((Result<[MASDKCustomPermissionModel], MASDKCustomPermissionError>)) -> Void)

    var customPermissionHandlerObj: CustomPermissionsCompletionHandler?
    var permissionsRequestList: [MASDKCustomPermissionModel]?
    var miniAppTitle: String = "MiniApp"

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.tableView.tableFooterView = UIView(frame: .zero)
        self.addFooterInfo()
    }

    @IBAction func saveCustomPermission(_ sender: UIBarButtonItem) {
        guard let permissionRequest = permissionsRequestList else {
            return
        }
        customPermissionHandlerObj?(.success(permissionRequest))
        self.dismiss(animated: true, completion: nil)
    }

    @objc func permissionValueChanged(_ sender: UISwitch) {
        if permissionsRequestList?.indices.contains(sender.tag) ?? false {
            let permissionModel = permissionsRequestList?[sender.tag]
            if sender.isOn {
                permissionModel?.isPermissionGranted = .allowed
            } else {
                permissionModel?.isPermissionGranted = .denied
            }
        }
        let allPermissionsDenied = permissionsRequestList?.allSatisfy {
            $0.isPermissionGranted == MiniAppCustomPermissionGrantedStatus.denied
            } ?? false
        if allPermissionsDenied {
            self.saveButton.title = "Save"
        } else {
            self.saveButton.title = "Allow"
        }
    }

    func getSwitchView(tagValue: Int) -> UISwitch {
        let switchView = UISwitch(frame: .zero)
        switchView.setOn(true, animated: true)
        switchView.tag = tagValue
        switchView.addTarget(self, action: #selector(permissionValueChanged(_:)), for: .valueChanged)
        return switchView
    }

    func addFooterInfo() {
        self.footerLabel.text = " \(miniAppTitle) wants to access the above permissions. Choose your preference accordingly.\n\n  You can also manage these permissions later in the Miniapp settings"
    }
}

// MARK: - UITableViewControllerDelegate
extension CustomPermissionsRequestViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return permissionsRequestList?.count ?? 0
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return permissionsRequestList?.count ?? 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MACustomPermissionCell", for: indexPath) as? MACustomPermissionCell {
            let permissionModel: MASDKCustomPermissionModel?
            if permissionsRequestList?.indices.contains(indexPath.row) ?? false {
                permissionModel = permissionsRequestList?[indexPath.row]
                cell.textLabel?.text = permissionModel?.permissionName.title
                cell.detailTextLabel?.text = permissionModel?.permissionDescription
                cell.detailTextLabel?.numberOfLines = 0
                cell.accessoryView = getSwitchView(tagValue: indexPath.row)
            }
            return cell
        }
        return UITableViewCell()
    }

//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        self.showProgressIndicator {
//            if let miniAppInfo = self.miniApps?[self.miniAppsSection?[indexPath.section] ?? ""]?[indexPath.row] {
//                self.currentMiniAppInfo = miniAppInfo
//                self.fetchMiniApp(for: miniAppInfo)
//                self.currentMiniAppTitle = miniAppInfo.displayName
//            }
//        }
//    }
}

