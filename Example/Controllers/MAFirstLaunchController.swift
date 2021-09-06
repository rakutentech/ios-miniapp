import UIKit
import MiniApp

class MAFirstLaunchController: UIViewController {

    @IBOutlet weak var miniAppMetaInfoContainer: UIView!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var miniAppName: UILabel!
    @IBOutlet weak var metaDataLabel: UILabel!
    @IBOutlet weak var miniAppVersion: UILabel!
    @IBOutlet weak var miniAppImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonsContainer: UIView!

    weak var launchScreenDelegate: MALaunchScreenDelegate?
    var miniAppInfo: MiniAppInfo?
    var miniAppManifest: MiniAppManifest? {
        didSet {
            requiredPermissions = miniAppManifest?.requiredPermissions ?? []
            optionalPermissions = miniAppManifest?.optionalPermissions ?? []
            customMetaData = miniAppManifest?.customMetaData ?? [:]
        }
    }
    private var permissionsCollections: [MASDKCustomPermissionModel]?
    private var requiredPermissions: [MASDKCustomPermissionModel] = []
    private var optionalPermissions: [MASDKCustomPermissionModel] = []
    private var customMetaData: [String: String] = [:]
    var isManifestUpdated: Bool = false
    var showScopes: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        permissionsCollections = requiredPermissions + optionalPermissions
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let footerView = tableView.tableFooterView else {
            return
        }

        let width = tableView.bounds.size.width
        let size = footerView.systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height))

        footerView.frame.size.height = size.height + buttonsContainer.frame.height
        tableView.tableFooterView = footerView
    }

    func setupUI() {
        miniAppMetaInfoContainer.roundCorners(radius: 10)
        acceptButton.roundedCornerButton()
        closeButton.roundedCornerButton(color: tintColor)
        miniAppName.text = miniAppInfo?.displayName
        miniAppVersion.text = "Version: " + (miniAppInfo?.version.versionTag)!
        miniAppImageView.loadImage(miniAppInfo!.icon, placeholder: "image_placeholder", cache: nil)
        metaDataLabel.text = "Custom MetaData: " + customMetaData.JSONString
    }

    @IBAction func acceptButtonPressed(_ sender: UIButton) {
        if let miniAppId = miniAppInfo?.id {
            MiniApp.shared().setCustomPermissions(forMiniApp: miniAppId, permissionList: permissionsCollections ?? [])
            launchScreenDelegate?.didUserResponded(agreed: true, miniAppInfo: miniAppInfo)
            dismiss(animated: true, completion: nil)
        } else {
            displayAlert(title: MASDKLocale.localize("miniapp.sdk.ios.error.title"), message: MASDKLocale.localize("miniapp.sdk.ios.error.message.miniapp"))
        }
    }

    @IBAction func closeButtonPressed(_ sender: UIButton) {
        launchScreenDelegate?.didUserResponded(agreed: false, miniAppInfo: miniAppInfo)
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewControllerDelegate
extension MAFirstLaunchController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return permissionsCollections?.count ?? 0
        }
        return showScopes ? 1 : 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if
            showScopes,
            indexPath.section == 1,
            let cell = tableView.dequeueReusableCell(withIdentifier: "FirstLaunchScopesCell", for: indexPath) as? FirstLaunchScopesCell
        {
                cell.scopesTitleLabel.text = "Requested Scopes"
                if let manifest = miniAppManifest {
                    guard let permissions = manifest.accessTokenPermissions
                    else {
                        cell.scopesDescriptionLabel.text = "No requested scopes found"
                        return cell
                    }
                    cell.scopesDescriptionLabel.text = permissions.filter({ $0.audience == "rae" }).first?.scopes.joined(separator: ", ")
                } else {
                    cell.scopesDescriptionLabel.text = "Manifest is not available"
                }
                return cell
        }
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: "FirstLaunchCustomPermissionCell", for: indexPath) as? FirstLaunchCustomPermissionCell {
            let permissionModel: MASDKCustomPermissionModel?
            if requiredPermissions.indices.contains(indexPath.row) {
                permissionModel = requiredPermissions[indexPath.row]
                cell.permissionTitle?.attributedText = NSMutableAttributedString()
                    .normalText(permissionModel?.permissionName.title ?? "")
                    .highlight(" (Required)", color: tintColor)
                cell.permissionDescription?.text = permissionModel?.permissionDescription
                cell.toggle.isHidden = true
            } else {
                if optionalPermissions.indices.contains(indexPath.row - (requiredPermissions.count)) {
                    permissionModel = optionalPermissions[indexPath.row - (requiredPermissions.count)]
                    cell.permissionTitle?.text = permissionModel?.permissionName.title
                    cell.permissionDescription?.text = permissionModel?.permissionDescription
                    cell.toggle.isHidden = false
                }
            }
            cell.toggle.tag = indexPath.row
            cell.toggle.isOn = true
            cell.toggle.addTarget(self, action: #selector(permissionValueChanged(_:)), for: .valueChanged)
            return cell
        }
        return UITableViewCell()
    }

    @objc func permissionValueChanged(_ sender: UISwitch) {
        if permissionsCollections?.indices.contains(sender.tag) ?? false {
            let permissionModel = permissionsCollections?[sender.tag]
            if sender.isOn {
                permissionModel?.isPermissionGranted = .allowed
            } else {
                permissionModel?.isPermissionGranted = .denied
            }
        }
    }
}

protocol MALaunchScreenDelegate: AnyObject {
    func didUserResponded(agreed: Bool, miniAppInfo: MiniAppInfo?)
}

class FirstLaunchCustomPermissionCell: UITableViewCell {

    @IBOutlet weak var permissionTitle: UILabel!
    @IBOutlet weak var permissionDescription: UILabel!
    @IBOutlet weak var toggle: UISwitch!

    override func prepareForReuse() {
        super.prepareForReuse()
        toggle.isOn = true
        permissionTitle.text = ""
        permissionDescription.text = ""
    }
}

class FirstLaunchScopesCell: UITableViewCell {

    @IBOutlet weak var scopesTitleLabel: UILabel!
    @IBOutlet weak var scopesDescriptionLabel: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
