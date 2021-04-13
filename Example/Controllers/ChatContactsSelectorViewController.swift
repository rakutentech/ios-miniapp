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
    var messageSent = false
    var selectedContacts: [MAContact]? {
        didSet {
            buttonSend?.isEnabled = (selectedContacts?.count ?? 0) > 0
        }
    }

    weak var contactDelegate: ContactsListDelegate?
    var contactsHandlerJob: ((Result<[String]?, MASDKError>) -> Void)?
    var contactHandlerJob: ((Result<String?, MASDKError>) -> Void)?

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

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // if the message was not sent by this controller and that we are in a single contact picker that did not pick
        if !messageSent && !(shouldHideSendButton() && selectedContacts?.count ?? 0 > 0) {
            contactDelegate?.contactsController(contactsController, didSelect: nil)
        }
    }

    func refreshUI() {
        if message?.action != nil {
            buttonAction?.setTitle(message?.caption ?? " ", for: .normal)
        } else {
            buttonAction?.isHidden = true
            buttonAction?.setTitle(nil, for: .normal)
        }
        labelMessage?.text = message?.text

        if !retrieveImage() {
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

    func retrieveImage() -> Bool {
        if let imageUrlString = message?.image {
            if let image = imageUrlString.convertBase64ToImage() {
                imageView?.image = image
                return true
            } else if let url = URL(string: imageUrlString) {
                imageView?.loadImage(url, placeholder: "Rakuten", cache: imageCache)
                return true
            }
        }
        return false
    }

    func shouldHideSendButton() -> Bool {
        contactToSend == nil && !multipleSelection
    }

    @IBAction func sendMessage() {
        if selectedContacts != nil {
            contactsHandlerJob?(.success(selectedContacts?.map { $0.id }))
        } else if contactToSend != nil {
            contactHandlerJob?(.success(contactToSend?.id))
        }
        messageSent = true
        dismiss(animated: true)
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
    func contactsController(_ contactsController: ContactsListSettingsTableViewController?, didSelect contact: [MAContact]?) {
        selectedContacts = contact
        contactDelegate?.contactsController(contactsController, didSelect: contact)
    }
}
