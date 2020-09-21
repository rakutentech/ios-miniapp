import UIKit
import MiniApp

class ManageCustomPermissionsViewController: UITableViewController {

    var downloadedMiniApps: [[MiniAppInfo: [MASDKCustomPermissionModel]]] = [[:]]
    let imageCache = ImageCache()
    let selectedMiniAppPermission = [MASDKCustomPermissionModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame: .zero)
    }

    override func viewWillAppear(_ animated: Bool) {
        downloadedMiniApps = MiniApp.shared().listDownloadedWithCustomPermissions() ?? []
        self.tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CustomPermissionList" {
            guard let index = self.tableView.indexPathForSelectedRow else {
                return
            }

            let permissionListController = segue.destination as? CustomPermissionsListViewController
            if downloadedMiniApps.indices.contains(index.row) {
                let miniApp = downloadedMiniApps[index.row]
                permissionListController?.permissionList = Array(miniApp.values)[0]
                permissionListController?.miniAppId = Array(miniApp.keys)[0].id
            }
        }
    }
}

extension ManageCustomPermissionsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downloadedMiniApps.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MiniAppPermissionsCell", for: indexPath) as? MiniAppCell {
            if downloadedMiniApps.indices.contains(indexPath.row) {
                let dict = downloadedMiniApps[indexPath.row]
                for (miniAppInfo, permissionModelList) in dict {
                    cell.titleLabel?.text = miniAppInfo.displayName ?? "Null"
                    cell.detailedTextLabel.text = getDescriptionText(permissionsList: permissionModelList)
                    cell.icon?.image = UIImage(named: "image_placeholder")
                    cell.icon?.loadImage(miniAppInfo.icon, placeholder: "image_placeholder", cache: imageCache)
                }
                return cell
            }
        }
        return UITableViewCell()
    }

    func getDescriptionText(permissionsList: [MASDKCustomPermissionModel]) -> String {
        if permissionsList.allSatisfy({$0.isPermissionGranted.boolValue == false}) {
            return "DENIED"
        } else {
            let allowedList = permissionsList.filter { $0.isPermissionGranted.boolValue == true }
            let descriptionText = (allowedList.map {
                String($0.permissionName.title)
            }).joined(separator: ", ")

            return descriptionText
        }
    }
}
