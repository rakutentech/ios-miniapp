import UIKit
import MiniApp

class CustomPermissionsTableViewController: UITableViewController {

    typealias CustomPermissionsCompletionHandler = (((Result<[MASDKCustomPermissionModel], Error>)) -> Void)

    var customPermissionHandlerObj: CustomPermissionsCompletionHandler?
    var permissionsRequestList: [MASDKCustomPermissionModel]?
    var miniAppTitle: String = "MiniApp"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.addBarButtonItems()
        self.addFooterInfo()
    }

    func addBarButtonItems() {
        let allowBarButtonItem = UIBarButtonItem(title: "Allow", style: .done, target: self, action: #selector(allowPermissions))
        let dontAllowBarButtonItem = UIBarButtonItem(title: "Don't Allow", style: .done, target: self, action: #selector(dontAllowPermissions))
        self.navigationItem.rightBarButtonItem  = allowBarButtonItem
        self.navigationItem.leftBarButtonItem  = dontAllowBarButtonItem
    }

    @objc func allowPermissions() {
        guard let permissionRequest = permissionsRequestList else {
            return
        }
        customPermissionHandlerObj?(.success(permissionRequest))
        self.dismiss(animated: true, completion: nil)
    }

    @objc func dontAllowPermissions() {
        let alert = UIAlertController(title: "Are you sure you don't want to allow any of the permissions?", message: "", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            self.permissionsRequestList?.forEach {
                $0.isPermissionGranted = .denied
            }
            self.customPermissionHandlerObj?(.success(self.permissionsRequestList!))
            self.dismiss(animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        alert.addAction(yesAction)
        self.present(alert, animated: true, completion: nil)
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
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }

    func getSwitchView(tagValue: Int) -> UISwitch {
        let switchView = UISwitch(frame: .zero)
        switchView.setOn(true, animated: true)
        switchView.tag = tagValue
        switchView.addTarget(self, action: #selector(permissionValueChanged(_:)), for: .valueChanged)
        return switchView
    }
}

extension CustomPermissionsTableViewController {

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
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

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return permissionsRequestList?.count ?? 0
    }

    func addFooterInfo() {
        let footerLabel = UILabel()
        footerLabel.text = "  \(miniAppTitle) wants to access the above permissions. Choose your preference accordingly.\n\n  You can also manage these permissions later in the Miniapp settings"
        footerLabel.textAlignment = .center
        footerLabel.textColor = .gray
        footerLabel.numberOfLines = 0
        tableView.addSubview(footerLabel)
        footerLabel.translatesAutoresizingMaskIntoConstraints = false
        footerLabel.bottomAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.bottomAnchor).isActive = true
        footerLabel.widthAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.widthAnchor).isActive = true
    }
}
