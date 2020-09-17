import UIKit
import MiniApp

class ManageCustomPermissionsViewController: UITableViewController {

    var downloadedMiniApps: [MiniAppInfo]? = []
    let imageCache = ImageCache()

    override func viewDidLoad() {
        super.viewDidLoad()
//        downloadedMiniApps = MiniApp.shared().getDownloadedMiniAppsInfoList()
        self.tableView.tableFooterView = UIView(frame: .zero)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MiniAppPermissionsCell", for: indexPath) as? MiniAppCell {
            if downloadedMiniApps?.indices.contains(indexPath.row) ?? false {
                let miniAppDetail = downloadedMiniApps?[indexPath.row]
                cell.titleLabel?.text = miniAppDetail?.displayName ?? "Null"
                cell.icon?.image = UIImage(named: "image_placeholder")
                cell.icon?.loadImage(miniAppDetail!.icon, placeholder: "image_placeholder", cache: imageCache)
                return cell
            }
        }

        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downloadedMiniApps?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
