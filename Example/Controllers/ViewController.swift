import UIKit
import MiniApp
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    let refreshControl = UIRefreshControl()
    let adsDisplayer = AdMobDisplayer()
    var unfilteredResults: [MiniAppInfo]? {
        didSet {
            self.decodeResponse = self.unfilteredResults
            executeSearch(searchText: self.searchBar.text ?? "")
        }
    }
    var decodeResponse: [MiniAppInfo]? {
        didSet {
            if let list = self.decodeResponse, !(Config.userDefaults?.bool(forKey: Config.Key.isPreviewMode.rawValue) ?? false) {
                self.miniAppsSection = nil
                self.miniApps = ["": list]
            } else {
                self.miniApps = nil
                self.miniAppsSection = self.decodeResponse?.map {
                    $0.id
                }.unique()
                self.miniApps = self.decodeResponse?.dictionaryFilteredBy(index: { $0.id })
            }

        }
    }
    var miniApps: [String: [MiniAppInfo]]?
    var miniAppsSection: [String]?
    var currentMiniAppInfo: MiniAppInfo?
    var currentMiniAppView: MiniAppDisplayDelegate?
    let imageCache = ImageCache()
    let locationManager = CLLocationManager()
    var permissionHandlerObj: PermissionCompletionHandler?
    var currentMiniAppTitle: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.viewControllers = [self]
        self.navigationItem.hidesBackButton = true
        refreshControl.addTarget(self, action: #selector(refreshList(_:)), for: .valueChanged)
        self.tableView.refreshControl = refreshControl
        locationManager.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        fetchAppList(inBackground: self.miniApps?.count ?? 0 > 0)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DisplayMiniApp" {
            guard let miniAppDisplay = currentMiniAppView else {
                displayAlert(title: MASDKLocale.localize("miniapp.sdk.ios.error.title"), message: MASDKLocale.localize("miniapp.sdk.ios.error.message.miniapp"), dismissController: true)
                return
            }

            let displayController = segue.destination as? DisplayNavigationController
            displayController?.miniAppInfo = currentMiniAppInfo
            displayController?.miniAppDisplay = miniAppDisplay
            currentMiniAppInfo = nil
            currentMiniAppView = nil
        } else if segue.identifier == "CustomConfiguration" {
            if let navigationController = segue.destination as? UINavigationController,
                let customSettingsController = navigationController.topViewController as? SettingsTableViewController {
                customSettingsController.configUpdateDelegate = self
            }
        }
    }

    func showFirstTimeLaunchScreen(miniAppInfo: MiniAppInfo) {
        if isMiniAppLaunchedAlready(key: miniAppInfo.id) {
            compareMiniAppMetaData(miniAppInfo: miniAppInfo) { (result) in
                switch result {
                case .success:
                    self.displayMiniApp(miniAppInfo: miniAppInfo)
                case .failure(let error):
                    self.displayAlert(title: MASDKLocale.localize("miniapp.sdk.ios.error.title"), message: error.localizedDescription, dismissController: true)
                }
            }
        } else {
            fetchMiniAppMetaData(miniAppInfo: miniAppInfo)
        }
    }

    func fetchMiniAppMetaData(miniAppInfo: MiniAppInfo) {
        MiniApp.shared(with: Config.current()).getMiniAppManifest(miniAppId: miniAppInfo.id, miniAppVersion: miniAppInfo.version.versionId) { (result) in
            switch result {
            case .success(let manifestData):
                self.displayFirstTimeLaunchScreen(
                    reqPermissions: manifestData.requiredPermissions ?? [],
                    optPermissions: manifestData.optionalPermissions ?? [],
                    miniAppInfo: miniAppInfo,
                    customMetaData: manifestData.customMetaData ?? [:])
            case .failure:
                self.displayAlert(title: MASDKLocale.localize("miniapp.sdk.ios.error.title"), message: MASDKLocale.localize("miniapp.sdk.ios.error.message.single"), dismissController: true)
            }
        }
    }

    func compareMiniAppMetaData(miniAppInfo: MiniAppInfo, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard let downloadedManifest = MiniApp.shared(with: Config.current()).getDownloadedManifest(miniAppId: miniAppInfo.id) else {
            return completionHandler(.success(true))
        }
        MiniApp.shared(with: Config.current()).getMiniAppManifest(miniAppId: miniAppInfo.id, miniAppVersion: miniAppInfo.version.versionId) { (result) in
            switch result {
            case .success(let manifestData):
                self.checkIfManifestChanged(latestManifest: manifestData, oldManifest: downloadedManifest, miniAppInfo: miniAppInfo)
            case .failure(let error):
                if error.isDeviceOfflineDownloadError() {
                    self.displayMiniApp(miniAppInfo: miniAppInfo)
                } else {
                    completionHandler(.failure(error))
                }
            }
        }
    }

    func checkIfManifestChanged(latestManifest: MiniAppManifest, oldManifest: MiniAppManifest, miniAppInfo: MiniAppInfo) {
        let cachedPermissions = MiniApp.shared().getCustomPermissions(forMiniApp: miniAppInfo.id)
        let cachedAllowedPermissions = cachedPermissions.filter { $0.isPermissionGranted.boolValue == true }

        let requiredPermissions = filterPermissions(permsArray: latestManifest.requiredPermissions ?? [],
                                                    cachedPermissions: cachedAllowedPermissions)
        if oldManifest == latestManifest && requiredPermissions.count == 0 {
            self.displayMiniApp(miniAppInfo: miniAppInfo)
        } else {
                self.displayFirstTimeLaunchScreen(reqPermissions: latestManifest.requiredPermissions ?? [],
                                                  optPermissions: latestManifest.optionalPermissions ?? [],
                                                  miniAppInfo: miniAppInfo,
                                                  manifestUpdated: true,
                                                  customMetaData: latestManifest.customMetaData ?? [:])
        }
    }

    func filterPermissions(permsArray: [MASDKCustomPermissionModel], cachedPermissions: [MASDKCustomPermissionModel]) -> [MASDKCustomPermissionModel] {
        return permsArray.filter {
            !cachedPermissions.contains($0)
        }
    }

    func displayFirstTimeLaunchScreen(reqPermissions: [MASDKCustomPermissionModel],
                                      optPermissions: [MASDKCustomPermissionModel],
                                      miniAppInfo: MiniAppInfo,
                                      manifestUpdated: Bool? = false,
                                      customMetaData: [String: String]) {
        DispatchQueue.main.async {
            if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MAFirstTimeLaunch") as? MAFirstLaunchController {
                self.currentMiniAppInfo = miniAppInfo
                viewController.miniAppInfo = miniAppInfo
                viewController.requiredPermissions = reqPermissions
                viewController.optionalPermissions = optPermissions
                viewController.isManifestUpdated = manifestUpdated ?? false
                viewController.customMetaData = customMetaData
                viewController.launchScreenDelegate = self
                viewController.modalPresentationStyle = .fullScreen
                self.present(viewController, animated: true)
            }
        }
    }

    func displayMiniApp(miniAppInfo: MiniAppInfo) {
        self.showProgressIndicator {
            self.currentMiniAppInfo = miniAppInfo
            self.fetchMiniApp(for: miniAppInfo)
            self.currentMiniAppTitle = miniAppInfo.displayName
        }
    }
}

// MARK: - Actions
extension ViewController {
    @IBAction func refreshList(_ sender: UIRefreshControl) {
        fetchAppList(inBackground: false)
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
        if let miniAppInfo = self.miniApps?[self.miniAppsSection?[indexPath.section] ?? ""]?[indexPath.row] {
            self.showFirstTimeLaunchScreen(miniAppInfo: miniAppInfo)
        }
    }
}

// MARK: - SettingsDelegate
extension ViewController: SettingsDelegate {
    func didSettingsUpdated(controller: SettingsTableViewController, updated miniAppList: [MiniAppInfo]?) {
        self.unfilteredResults?.removeAll()
        self.unfilteredResults = miniAppList
        self.tableView.reloadData()
    }
}

extension ViewController: MALaunchScreenDelegate {
    func didUserResponded(agreed: Bool, miniAppInfo: MiniAppInfo?) {
        if agreed {
            guard let info = miniAppInfo else {
                return
            }
            self.showProgressIndicator {
                self.fetchMiniApp(for: info)
                self.currentMiniAppTitle = info.displayName
            }
        }
    }
}
extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let search = searchBar.text else {
            return
        }

        if search.hasHTTPPrefix, let searchURL = URL(string: search) {
            loadMiniAppUsingURL(searchURL)
        } else if self.miniApps?[search] != nil {
            fetchAppInfo(for: search)
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        executeSearch(searchText: searchText)
    }

    func executeSearch(searchText: String) {
        defer {
            tableView.reloadData()
            searchBar.reloadInputViews()
        }
        searchBar.returnKeyType = .done

        guard !searchText.isEmpty else {
            decodeResponse = unfilteredResults
            return
        }

        decodeResponse = unfilteredResults?.filter {
            $0.displayName?.uppercased().contains(searchText.uppercased()) == true
            || $0.id.uppercased().contains(searchText.uppercased()) == true
        }

        if decodeResponse?.isEmpty == true && !searchText.isEmpty {
            searchBar.returnKeyType = .go // load by ID or URL
        }
    }
}
