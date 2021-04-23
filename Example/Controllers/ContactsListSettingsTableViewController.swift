import UIKit
import MiniApp

protocol ContactsListDelegate: class {
    func contactsController(_ contactsController: ContactsListSettingsTableViewController?, didSelect contact: [MAContact]?)
}

class ContactsListSettingsTableViewController: UITableViewController {

    var userContactList: [MAContact]? = []
    weak var contactDelegate: ContactsListDelegate?
    var selectedContacts = [MAContact]()
    var allowMultipleSelection = true

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareRandomContactList()
        self.tableView.separatorStyle = .singleLine
    }

    func prepareRandomContactList() {
        userContactList = getContactList()
        if userContactList?.count ?? 0 == 0 {
            userContactList = []
            for autogen in 0...9 {
                userContactList?.append(
                    MAContact(id: UUID().uuidString,
                              name: self.randomFakeName(),
                              email: "name.\(autogen)@example.com"))
            }
            updateContactList(list: self.userContactList)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell? ?? UITableViewCell()
        if let userContactList = userContactList, userContactList.indices.contains(indexPath.row) {
            let contact = userContactList[indexPath.row]
            cell.detailTextLabel?.text = "id: \(contact.id)"
            cell.textLabel?.text = contact.name
            if contactDelegate != nil {
                if allowMultipleSelection {
                    cell.accessoryType = selectedContacts.contains(contact) ? .checkmark : .none
                } else {
                    cell.accessoryType = .disclosureIndicator
                }
            }
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let contact = userContactList?[indexPath.row] {

            if allowMultipleSelection {
                if selectedContacts.contains(contact) {
                    selectedContacts.removeAll { contactToRemove -> Bool in
                        contactToRemove == contact
                    }
                } else {
                    selectedContacts.append(contact)
                }
                tableView.reloadRows(at: [indexPath], with: .automatic)
            } else {
                tableView.deselectRow(at: indexPath, animated: true)
                selectedContacts = [contact]
            }
            contactDelegate?.contactsController(self, didSelect: selectedContacts)
        }
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if allowMultipleSelection, let selectedContact = userContactList?[indexPath.row] {
            selectedContacts.removeAll(where: { contact in
                contact == selectedContact
            })
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        userContactList?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return contactDelegate == nil
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if userContactList?.indices.contains(indexPath.row) ?? false {
                userContactList?.remove(at: indexPath.row)
                updateContactList(list: self.userContactList)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }

    @IBAction func addContact() {
        self.addCustomContactId(title: "Please enter the custom ID you would like to add in Contacts", message: "")
    }

    func addCustomContactId(title: String, message: String) {
        DispatchQueue.main.async {
            self.getInputFromAlertWithTextField(title: title, message: message, textFieldDefaultValue: UUID().uuidString) { (_, textField) in
                if let textField = textField, let contactId = textField.text, contactId.count > 0, !contactId.trimTrailingWhitespaces().isEmpty {
                    let contactListCount = self.userContactList?.count ?? 0
                    self.userContactList?.append(MAContact(id: contactId,
                                                           name: self.randomFakeName(),
                                                           email: "name.\(contactListCount)@example.com"))
                    updateContactList(list: self.userContactList)
                    self.tableView.reloadData()
                } else {
                    self.addCustomContactId(title: "Invalid Contact ID, please try again", message: "Enter valid contact and select Ok")
                }
            }
        }
    }

    func getInputFromAlertWithTextField(title: String? = nil, message: String? = nil, keyboardType: UIKeyboardType? = .asciiCapable, textFieldDefaultValue: String?, handler: ((UIAlertAction, UITextField?) -> Void)? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let alert = UIAlertController(title: title,
                message: message,
                preferredStyle: .alert)
            var textObserver: NSObjectProtocol?

            let okAction = UIAlertAction(title: MASDKLocale.localize(.ok), style: .default) { (action) in
                if !alert.textFields![0].text!.isEmpty {
                    handler?(action, alert.textFields?.first)
                } else {
                    handler?(action, nil)
                }
                if let observer = textObserver {
                    NotificationCenter.default.removeObserver(observer)
                }
            }

            alert.addTextField { (textField) in
                textObserver = NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) {_ in
                    okAction.isEnabled = !(textField.text?.isEmpty ?? true)
                }
                textField.text = textFieldDefaultValue
                if let type = keyboardType {
                    textField.keyboardType = type
                }
                textField.clearButtonMode = .whileEditing
            }

            okAction.isEnabled = !(textFieldDefaultValue?.isEmpty ?? true)
            alert.addAction(UIAlertAction(title: MASDKLocale.localize(.cancel), style: .cancel, handler: nil))
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }

    func randomFakeName() -> String {
        randomFakeFirstName() + " " + randomFakeLastName()
    }

    func randomFakeFirstName() -> String {
        let firstNameList = ["哲也", "太郎", "ピエール", "レオ", "Yvonne", "Jamie", "Leticia", "Priscilla", "Sidney", "Nancy", "Edmund", "Bill", "Megan"]
        return firstNameList.randomElement()!
    }

    func randomFakeLastName() -> String {
        let lastNameList = ["古室", "楽天", "ビラ", "ジョゼフ", "Andrews", "Casey", "Gross", "Lane", "Thomas", "Patrick", "Strickland", "Nicolas", "Freeman"]
        return lastNameList.randomElement()!
    }
}
