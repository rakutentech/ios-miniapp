import UIKit
import MiniApp

class DeeplinkErrorViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var errorDescTextview: UITextView!
    @IBOutlet weak var errorTitleLabel: UILabel!
    var errorType: DeeplinkErrorDescriptionType? = .noLongerExists
    var errorTitle: DeeplinkErrorTitleType?

    override func viewWillAppear(_ animated: Bool) {
        errorDescTextview.createHyperLinkAttributedText(
            fullText: MASDKLocale.localize(errorType?.rawValue ?? "deeplink.ui.miniapp.error.desc"),
            textToLink: MASDKLocale.localize("deeplink.ui.miniapp.error.help.center"),
            urlString: MASDKLocale.localize("deeplink.ui.miniapp.error.help.center.hyperlink"))
        guard let title = errorTitle else { return }
        errorTitleLabel.text = String(format: MASDKLocale.localize(title.rawValue))
    }
    @IBAction func close(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

enum DeeplinkErrorDescriptionType: String {
    case noLongerExists = "deeplink.ui.miniapp.error.desc"
    case permissionError = "deeplink.ui.miniapp.permissionerror.desc"
    case qrCodeExpired = "deeplink.ui.qr.error.desc"
    case cannotBePreviewed, versionNotValid = "deeplink.ui.version.notvalid.error.desc"
}

enum DeeplinkErrorTitleType: String {
    case qrCodeExpiredTitle = "deeplink.ui.qr.error.title"
    case cannotBePreviewedTitle = "deeplink.ui.preview.unavailable.error.title"
    case versionNotValidTitle = "deeplink.ui.version.notvalid.error.title"
}
