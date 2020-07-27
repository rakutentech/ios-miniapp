import UIKit
import MiniApp
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let refreshControl = UIRefreshControl()

    var decodeResponse: [MiniAppInfo]? {
        didSet {
            if let list = self.decodeResponse, !(Config.userDefaults?.bool(forKey: Config.Key.isTestMode.rawValue) ?? false) {
                self.miniAppsSection = nil
                self.miniApps = ["": list]
            } else {
                self.miniApps = nil
                self.miniAppsSection = self.decodeResponse?.map { $0.displayName ?? "-" }
                self.miniApps = self.decodeResponse?.dictionaryFilteredBy(index: { $0.displayName ?? "-" })
            }

        }
    }
    var miniApps: [String: [MiniAppInfo]]?
    var miniAppsSection: [String]?
    var currentMiniAppInfo: MiniAppInfo?
    var currentMiniAppView: MiniAppDisplayProtocol?
    let imageCache = ImageCache()
    let locationManager = CLLocationManager()
    var permissionHandlerObj: PermissionCompletionHandler?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.viewControllers = [self]
        self.navigationItem.hidesBackButton = true
        refreshControl.addTarget(self, action: #selector(refreshList(_:)), for: .valueChanged)
        self.tableView.refreshControl = refreshControl
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        fetchAppList(inBackground: self.miniApps?.count ?? 0 > 0)
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
                customSettingsController.configUpdateDelegate = self
            }
        }
    }
}

// MARK: - Actions
extension ViewController {
    @IBAction func refreshList(_ sender: UIRefreshControl) {
        fetchAppList(inBackground: false)
    }

    @IBAction func actionShowMiniAppById() {
        fetchMiniAppUsingId(title: NSLocalizedString("input_miniapp_title", comment: ""))
    }
}

// MARK: - UITableViewControllerDelegate
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let miniAppsSection = self.miniAppsSection {
            return miniAppsSection[section]
        }
        return nil
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return miniApps?[miniAppsSection?[section] ?? ""]?.count ?? 0
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return miniAppsSection?.count ?? 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MiniAppCell", for: indexPath) as? MiniAppCell {
            let miniAppDetail = miniApps?[miniAppsSection?[indexPath.section] ?? ""]?[indexPath.row]
            cell.titleLabel?.text = miniAppDetail?.displayName
            cell.titleLabel?.text = miniAppDetail?.displayName ?? "Null"
            cell.detailedTextLabel?.text = "Version: " + (miniAppDetail?.version.versionTag ?? "N/A")
            cell.icon?.image = UIImage(named: "image_placeholder")
            cell.icon?.loadImage(miniAppDetail!.icon, placeholder: "image_placeholder", cache: imageCache)
            return cell
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.showProgressIndicator {
            if let miniAppInfo = self.miniApps?[self.miniAppsSection?[indexPath.section] ?? ""]?[indexPath.row] {
                self.currentMiniAppInfo = miniAppInfo
                self.fetchMiniApp(for: miniAppInfo)
            }
        }
    }
}

// MARK: - SettingsDelegate
extension ViewController: SettingsDelegate {
    func didSettingsUpdated(controller: SettingsTableViewController, updated miniAppList: [MiniAppInfo]?) {
        self.decodeResponse?.removeAll()
        self.decodeResponse = miniAppList
        self.tableView.reloadData()
    }
}
