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
        let podBundle: Bundle = Bundle.miniAppSDKBundle()
        let nib = UINib(nibName: "MACustomPermissionCell", bundle: podBundle)
        self.tableView.register(nib, forCellReuseIdentifier: "MACustomPermissionCell")
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.addFooterInfo()
    }

    @IBAction func saveCustomPermission(_ sender: UIBarButtonItem) {
        guard let permissionRequest = permissionsRequestList else {
            return
        }
        self.dismiss(animated: true, completion: {
            self.customPermissionHandlerObj?(.success(permissionRequest))
        })
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
            self.saveButton.title = MASDKLocale.localize(.save)
        } else {
            self.saveButton.title = MASDKLocale.localize(.allow)
        }
    }

    func addFooterInfo() {
        footerLabel.text = String(format: MASDKLocale.localize(.firstLaunchFooter), miniAppTitle)
    }
}

// MARK: - UITableViewControllerDelegate
extension CustomPermissionsRequestViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        permissionsRequestList?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MACustomPermissionCell", for: indexPath) as? MACustomPermissionCell {
            let permissionModel: MASDKCustomPermissionModel?
            if permissionsRequestList?.indices.contains(indexPath.row) ?? false {
                permissionModel = permissionsRequestList?[indexPath.row]
                cell.permissionTitle?.text = permissionModel?.permissionName.title
                cell.permissionDescription?.text = permissionModel?.permissionDescription
                cell.toggle.tag = indexPath.row
                cell.toggle.isOn = permissionModel?.isPermissionGranted.boolValue ?? true
                cell.toggle.addTarget(self, action: #selector(permissionValueChanged(_:)), for: .valueChanged)
            }
            return cell
        }
        return UITableViewCell()
    }
}
