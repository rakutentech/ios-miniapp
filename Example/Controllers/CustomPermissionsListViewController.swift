import UIKit
import MiniApp

class CustomPermissionsListViewController: UITableViewController {

    var permissionList = [MASDKCustomPermissionModel]()
    var miniAppId = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame: .zero)
    }

    @IBAction func permissionValueChanged(_ sender: UISwitch) {
        if permissionList.indices.contains(sender.tag) {
            if sender.isOn {
                permissionList[sender.tag].isPermissionGranted = .allowed
            } else {
                permissionList[sender.tag].isPermissionGranted = .denied
            }
        }
        MiniApp.shared().setCustomPermissions(forMiniApp: miniAppId, permissionList: permissionList)
    }
}

extension CustomPermissionsListViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CustomPermissionCell", for: indexPath) as? CustomPermissionCell {
            if permissionList.indices.contains(indexPath.row) {
                let permission = permissionList[indexPath.row]
                cell.titleLabel.text = permission.permissionName.title
                cell.toggle.isOn = permission.isPermissionGranted.boolValue
                cell.toggle.tag = indexPath.row
                return cell
            }
        }

        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return permissionList.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
