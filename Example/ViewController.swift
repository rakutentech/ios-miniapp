import UIKit
import MiniApp

class ViewController: UITableViewController {

    var decodeResponse: [MiniAppInfo]?
    var currentMiniAppInfo: MiniAppInfo?
    var currentMiniAppView: MiniAppDisplayProtocol?
    let imageCache = ImageCache()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        fetchAppList()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func fetchAppList() {
        showProgressIndicator {
            MiniApp.shared(with: Config.getCurrent()).list { (result) in
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                }
                switch result {
                case .success(let responseData):
                    DispatchQueue.main.async {
                        self.decodeResponse = responseData
                        self.tableView.reloadData()
                        self.dismissProgressIndicator()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    self.displayAlert(title: NSLocalizedString("error_title", comment: ""), message: NSLocalizedString("error_list_message", comment: ""), dismissController: true)
                }
            }
        }
    }

    func fetchMiniApp(for appInfo: MiniAppInfo) {
        MiniApp.shared(with: Config.getCurrent()).create(appInfo: appInfo, completionHandler: { (result) in
            switch result {
            case .success(let miniAppDisplay):
                self.dismissProgressIndicator {
                    self.currentMiniAppView = miniAppDisplay
                    self.performSegue(withIdentifier: "DisplayMiniApp", sender: nil)
                }
            case .failure(let error):
                self.displayAlert(title: NSLocalizedString("error_title", comment: ""), message: NSLocalizedString("error_miniapp_download_message", comment: ""), dismissController: true) { _ in
                    self.fetchAppList()
                }
                print("Errored: ", error.localizedDescription)
            }
        }, messageInterface: self)
    }

    func fetchAppInfo(for miniAppID: String) {
        self.showProgressIndicator {
            MiniApp.shared(with: Config.getCurrent()).info(miniAppId: miniAppID) { (result) in

                switch result {
                case .success(let responseData):
                    self.currentMiniAppInfo = responseData
                    self.fetchMiniApp(for: responseData)
                case .failure(let error):
                    print(error.localizedDescription)
                    self.displayAlert(
                        title: NSLocalizedString("error_title", comment: ""),
                        message: NSLocalizedString("error_single_message", comment: ""),
                        dismissController: true)
                }
            }
        }
    }

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
        }
    }
}

extension UIImageView {
    func loadImage(_ url: URL, placeholder: String? = nil, cache: ImageCache? = nil) {

        if let cachedImage = cache?[url] {
            self.image = cachedImage
        } else if let imageName = placeholder {
            self.image = UIImage(named: imageName)
        } else {
            self.image = nil
        }

        UIImageView.downloadImage(url, for: self, cache: cache)
    }

    class func downloadImage(_ url: URL, for imageView: UIImageView, cache: ImageCache? = nil) {
        let tag = Int(Date().timeIntervalSince1970)
        imageView.tag = tag
        DispatchQueue.global().async { [weak imageView] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        if imageView?.tag == tag {
                            imageView?.image = image
                        } else {
                            print("image tag diff")
                        }
                        cache?[url] = image
                    }
                }
            }
        }
    }
}

extension ViewController: MiniAppMessageProtocol {
    func getUniqueId() -> String {
        guard let deviceId = UIDevice.current.identifierForVendor?.uuidString else {
            return ""
        }
        return deviceId
    }
}
