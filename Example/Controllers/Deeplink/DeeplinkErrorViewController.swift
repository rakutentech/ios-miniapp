import UIKit
import MiniApp

class DeeplinkErrorViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var errorDescTextview: UITextView!
    @IBOutlet weak var errorTitleLabel: UILabel!
    var errorType: DeeplinkErrorDescriptionType? = .miniAppNoLongerExists
    var errorTitle: DeeplinkErrorTitleType?
    var miniAppInfo: MiniAppInfo?

    override func viewWillAppear(_ animated: Bool) {
        errorDescTextview.createHyperLinkAttributedText(
            fullText: MASDKLocale.localize(errorType?.rawValue ?? "deeplink.ui.miniapp.error.desc"),
            textToLink: MASDKLocale.localize("deeplink.ui.miniapp.error.help.center"),
            urlString: MASDKLocale.localize("deeplink.ui.miniapp.error.help.center.hyperlink"))
        setErrorTitle(title: errorTitle)
    }

    @IBAction func close(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    func setErrorTitle(title: DeeplinkErrorTitleType? = DeeplinkErrorTitleType.qrCodeExpiredTitle) {
        guard let title = title else { return }
        if errorTitleLabel == nil { return }

        switch title {
        case .versionNotValidTitle:
            errorTitleLabel.text = String(format: MASDKLocale.localize(title.rawValue), miniAppInfo?.version.versionTag ?? "")
        case .cannotBePreviewedTitle:
            errorTitleLabel.text = String(format: MASDKLocale.localize(title.rawValue), miniAppInfo?.displayName ?? "MiniApp", miniAppInfo?.version.versionTag ?? "")
        default:
            errorTitleLabel.text = String(format: MASDKLocale.localize(title.rawValue))
        }
    }
}

enum DeeplinkErrorDescriptionType: String {
    case miniAppNoLongerExists = "deeplink.ui.miniapp.error.desc"
    case miniAppPermissionError = "deeplink.ui.miniapp.permissionerror.desc"

    case qrCodeExpired = "deeplink.ui.qr.error.desc"
    case cannotBePreviewed = "deeplink.ui.version.cannotBePreviewed.error.desc"
    case versionNotValid = "deeplink.ui.version.notvalid.error.desc"
}

enum DeeplinkErrorTitleType: String {
    case versionNotValidTitle = "deeplink.ui.version.notvalid.error.title"

    case qrCodeExpiredTitle = "deeplink.ui.qr.error.title"
    case cannotBePreviewedTitle = "deeplink.ui.preview.unavailable.error.title"
}
