import UIKit
import MiniApp

class ChatContactsSelectorViewController: UIViewController {
    var contactsController: ContactsListSettingsTableViewController?
    var multipleSelection = false {
        didSet {
            contactsController?.allowMultipleSelection = multipleSelection
        }
    }
    var sendById = false
    var messageSent = false
    var selectedContacts: [MAContact]? {
        didSet {
            changeButtonState()
        }
    }

    var contactsHandlerJob: ((Result<[String]?, MASDKError>) -> Void)?
    var contactHandlerJob: ((Result<String?, MASDKError>) -> Void)?

    @IBOutlet weak var labelTitle: UILabel?
    @IBOutlet weak var labelMessage: UITextView?
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

    fileprivate func sendCancel() {
        // if the message was not sent by this controller and that we are in a single contact picker that did not pick
        if !messageSent {
            contactsHandlerJob?(.success(nil))
            contactHandlerJob?(.success(nil))
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        sendCancel()
    }

    fileprivate func changeButtonState() {
        if let button = buttonSend {
            button.backgroundColor = canSend() ? UIColor(named: "Crimson") : .lightGray
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
        self.buttonSend?.isEnabled = true

        if !sendById {
            self.viewContact?.removeFromSuperview()
        } else {
            self.labelContactId?.text = selectedContacts?.first?.id
            self.labelContactName?.text = selectedContacts?.first?.name
            self.labelContactEmail?.text = selectedContacts?.first?.email
        }
        changeButtonState()
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

    fileprivate func canSend() -> Bool {
        return selectedContacts?.count ?? 0 > 0
    }

    @IBAction func sendMessage() {
        if canSend() {
            contactsHandlerJob?(.success(selectedContacts?.map { $0.id }))
            contactHandlerJob?(.success(selectedContacts?.first?.id))
            messageSent = true
            dismiss(animated: true)
        }
    }

    @IBAction func cancel() {
        selectedContacts?.removeAll()
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
            contactsController?.delegate = self
            contactsController?.allowMultipleSelection = multipleSelection
        }
    }
}

extension ChatContactsSelectorViewController: ContactsListDelegate {
    func contactsController(_ contactsController: ContactsListSettingsTableViewController?, didSelect contact: [MAContact]?) {
        selectedContacts = contact
    }
}
