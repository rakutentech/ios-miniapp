import UIKit
import MiniApp

class MAFirstLaunchController: UIViewController {

    @IBOutlet weak var miniAppMetaInfoContainer: UIView!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var miniAppName: UILabel!
    @IBOutlet weak var miniAppVersion: UILabel!
    @IBOutlet weak var miniAppImageView: UIImageView!
    weak var launchScreenDelegate: MALaunchScreenDelegate?

    var miniAppInfo: MiniAppInfo?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {
        miniAppMetaInfoContainer.roundCorners(radius: 10)
        acceptButton.roundedCornerButton()
        closeButton.addBorderAndColor(color: #colorLiteral(red: 0.7472071648, green: 0, blue: 0, alpha: 1), width: 1, cornerRadius: 20, clipsToBounds: true)
        self.miniAppName.text = self.miniAppInfo?.displayName
        self.miniAppVersion.text = "Version: " + (self.miniAppInfo?.version.versionTag)!
        self.miniAppImageView.loadImage(self.miniAppInfo!.icon, placeholder: "image_placeholder", cache: nil)
    }

    @IBAction func acceptButtonPressed(_ sender: UIButton) {
        _ = saveMiniAppLaunchInfo(isMiniAppLaunched: true, forKey: miniAppInfo!.id)
        launchScreenDelegate?.didUserResponded(agreed: true, miniAppInfo: miniAppInfo)
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func closeButtonPressed(_ sender: UIButton) {
        launchScreenDelegate?.didUserResponded(agreed: false, miniAppInfo: miniAppInfo)
        self.dismiss(animated: true, completion: nil)
    }
}

protocol MALaunchScreenDelegate: class {
    func didUserResponded(agreed: Bool, miniAppInfo: MiniAppInfo?)
}
