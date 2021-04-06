import UIKit
import MiniApp

class ChatContactsSelectorViewController: UIViewController {
    var contactsController: ContactsListSettingsTableViewController?
    weak var contactDelegate: ContactsListDelegate?
    @IBOutlet weak var labelTitle: UILabel?
    @IBOutlet weak var labelCaption: UILabel?
    @IBOutlet weak var labelMessage: UILabel?
    @IBOutlet weak var imageView: UIImageView?
    let imageCache = ImageCache()

    var message: MessageToContact? {
        didSet {
            refreshUI()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshUI()
    }

    func refreshUI() {
        labelTitle?.text = message?.title
        labelCaption?.text = message?.caption
        labelMessage?.text = message?.text
        var imageOK = false
        if let imageUrlString = message?.image {
            if let url = URL(string: imageUrlString) {
                imageOK = true
                imageView?.loadImage(url, placeholder: "Rakuten", cache: imageCache)
            } else if let imageData = Data(base64Encoded: imageUrlString, options: Data.Base64DecodingOptions.ignoreUnknownCharacters), let image = UIImage(data: imageData) {
                imageOK = true
                imageView?.image = image
            }
        }
        if !imageOK {
            imageView?.image = nil
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? ContactsListSettingsTableViewController {
            self.contactsController = dest
            self.contactsController?.contactDelegate = self.contactDelegate
        }
    }
}
