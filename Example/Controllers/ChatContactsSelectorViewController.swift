import UIKit
import MiniApp

class ChatContactsSelectorViewController: UIViewController {
    var contactsController: ContactsListSettingsTableViewController?
    var multipleSelection = false {
        didSet {
            contactsController?.allowMultipleSelection = multipleSelection
        }
    }
    var contactToSend: MAContact?
    var selectedContacts: [MAContact]? {
        didSet {
            buttonSend?.isEnabled = (selectedContacts?.count ?? 0) > 0
        }
    }

    weak var contactDelegate: ContactsListDelegate?
    var contactsHandlerJob: ((Result<[String], MASDKError>) -> Void)?
    var contactHandlerJob: ((Result<Void, MASDKError>) -> Void)?

    @IBOutlet weak var labelTitle: UILabel?
    @IBOutlet weak var labelMessage: UILabel?
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var buttonAction: UIButton?

    @IBOutlet weak var viewContact: UIView?
    @IBOutlet weak var labelContactName: UILabel?
    @IBOutlet weak var labelContactEmail: UILabel?
    @IBOutlet weak var labelContactId: UILabel?

    @IBOutlet weak var buttonSend: UIButton?

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
        if message?.action != nil {
            buttonAction?.setTitle(message?.caption ?? " ", for: .normal)
        } else {
            buttonAction?.isHidden = true
            buttonAction?.setTitle(nil, for: .normal)
        }
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
        self.buttonSend?.isHidden = shouldHideSendButton()
        if contactToSend == nil {
            self.viewContact?.removeFromSuperview()
        } else {
            self.buttonSend?.isEnabled = true
            self.labelContactId?.text = contactToSend?.id
            self.labelContactName?.text = contactToSend?.name
            self.labelContactEmail?.text = contactToSend?.email
        }
    }

    func shouldHideSendButton() -> Bool {
        contactToSend == nil && !multipleSelection
    }

    @IBAction func sendMessage() {
        if selectedContacts != nil {
            contactsHandlerJob?(.success(selectedContacts?.map { $0.id } ?? [] ))
        } else if contactToSend != nil {
            contactHandlerJob?(.success(()))
        }
        self.dismiss(animated: true)
    }

    @IBAction func sendAction() {
        if let urlString = message?.action, let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? ContactsListSettingsTableViewController {
            contactsController = dest
            contactsController?.contactDelegate = self
            contactsController?.allowMultipleSelection = multipleSelection
        }
    }
}

extension ChatContactsSelectorViewController: ContactsListDelegate {
    func contactsController(_ contactsController: ContactsListSettingsTableViewController, didSelect contact: [MAContact]?) {
        selectedContacts = contact
        contactDelegate?.contactsController(contactsController, didSelect: contact)
    }
}
