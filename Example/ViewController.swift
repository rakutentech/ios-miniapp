import UIKit
import MiniApp

class ViewController: UITableViewController, ConfigProtocol {

    var decodeResponse: [MiniAppInfo]?
    var currentMiniAppInfo: MiniAppInfo?
    var currentMiniAppView: MiniAppDisplayProtocol?
    let imageCache = ImageCache()
    let config = Config.getCurrent()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        fetchAppList()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DisplayMiniApp" {
            guard let miniAppInfo = self.currentMiniAppInfo, let miniAppDisplay = self.currentMiniAppView else {
                self.displayAlert(title: NSLocalizedString("error_title", comment: ""), message: NSLocalizedString("error_miniapp_message", comment: ""), dismissController: true)
                return
            }

            let displayController = segue.destination as? DisplayNavigationController
            displayController?.miniAppInfo = miniAppInfo
            displayController?.miniAppDisplay = miniAppDisplay
            self.currentMiniAppInfo = nil
            self.currentMiniAppView = nil
        } else if segue.identifier == "CustomConfiguration" {
            if let navigationController = segue.destination as? UINavigationController,
                let customSettingsController = navigationController.topViewController as? SettingsTableViewController {
                customSettingsController.configUpdateProtocol = self
            }
        }
    }
}

// MARK: - Actions
extension ViewController {
    @IBAction func refreshList(_ sender: UIRefreshControl) {
        fetchAppList()
    }

    @IBAction func actionShowMiniAppById() {
        self.displayTextFieldAlert(title: NSLocalizedString("input_miniapp_title", comment: "")) { (_, textField) in
            self.dismiss(animated: true) {
                if let textField = textField, let miniAppID = textField.text, miniAppID.count > 0 {
                    self.fetchAppInfo(for: miniAppID)
                } else {
                    self.displayAlert(
                        title: NSLocalizedString("error_title", comment: ""),
                        message: NSLocalizedString("error_incorrect_appid_message", comment: ""),
                        dismissController: true)
                }
            }
        }
    }
}

// MARK: - UITableViewControllerDelegate
extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return decodeResponse?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MiniAppCell", for: indexPath) as? MiniAppCell {
            let miniAppDetail = self.decodeResponse?[indexPath.row]
            cell.titleLabel?.text = miniAppDetail?.displayName
            cell.titleLabel?.text = miniAppDetail?.displayName ?? "Null"
            cell.detailedTextLabel?.text = "Version: " + (miniAppDetail?.version.versionTag ?? "N/A")
            cell.icon?.image = UIImage(named: "image_placeholder")
            cell.icon?.loadImage(miniAppDetail!.icon, placeholder: "image_placeholder", cache: imageCache)
            return cell
        }

        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.showProgressIndicator {
            if let miniAppInfo = self.decodeResponse?[indexPath.row] {
                self.currentMiniAppInfo = miniAppInfo
                self.fetchMiniApp(for: miniAppInfo)
            }
        }
    }

    /// Delegate called whenever Runtime configuration is changed from SettingsTableViewController
    func didConfigChanged() {
        self.decodeResponse?.removeAll()
        self.tableView.reloadData()
        fetchAppList()
    }
}
