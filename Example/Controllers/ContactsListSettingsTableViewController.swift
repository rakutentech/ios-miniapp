import UIKit
import MiniApp

protocol ContactsListDelegate: AnyObject {
    func contactsController(_ contactsController: ContactsListSettingsTableViewController?, didSelect contact: [MAContact]?)
}

class ContactsListSettingsTableViewController: UITableViewController {

    var bannerMessage: CGFloat = 0
    var userContactList: [MAContact]? = []
    weak var delegate: ContactsListDelegate?
    var selectedContacts = [MAContact]()
    var allowMultipleSelection = true

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareRandomContactList()
        tableView.separatorStyle = .singleLine
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: bannerMessage))
    }

    func prepareRandomContactList() {
        userContactList = getContactList()
        if userContactList?.count ?? 0 == 0 {
            userContactList = []
            repeat {
                let name = Self.randomFakeName()
                userContactList?.append(
                    MAContact(id: UUID().uuidString,
                              name: name,
                              email: Self.fakeMail(with: name)
                    )
                )
            } while (userContactList?.count ?? 10) < 10
            updateContactList(list: self.userContactList)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell? ?? UITableViewCell()
        if let userContactList = userContactList, userContactList.indices.contains(indexPath.row) {
            let contact = userContactList[indexPath.row]
            cell.detailTextLabel?.numberOfLines = 3
            let titleSize = cell.textLabel?.font.pointSize ?? 12
            var names = contact.name?.components(separatedBy: " ")
            cell.textLabel?.attributedText = NSMutableAttributedString()
                .normal(names?.removeFirst() ?? "", fontSize: titleSize)
                .bold(" " + (names?.joined() ?? ""), fontSize: titleSize)
            let size = cell.detailTextLabel?.font.pointSize ?? 10
            cell.detailTextLabel?.attributedText = NSMutableAttributedString()
                .bold("\(NSLocalizedString("contact.id", comment: "")): ", fontSize: size)
                .normal(contact.id, fontSize: size-3)
                .bold("\n\(NSLocalizedString("contact.email", comment: "")): ", fontSize: size)
                .normal(contact.email ?? "", fontSize: size)
            if delegate != nil {
                cell.accessoryType = selectedContacts.contains(contact) ? .checkmark : .none
            }
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let contact = userContactList?[indexPath.row] {
            if delegate == nil {
                editContact(title: "Edit Contact info",
                            index: indexPath.row,
                            contactId: contact.id,
                            contactName: contact.name,
                            contactEmail: contact.email)
                tableView.deselectRow(at: indexPath, animated: true)
            } else if allowMultipleSelection {
                if selectedContacts.contains(contact) {
                    selectedContacts.removeAll { contactToRemove -> Bool in
                        contactToRemove == contact
                    }
                } else {
                    selectedContacts.append(contact)
                }
                tableView.reloadRows(at: [indexPath], with: .automatic)
            } else {
                if selectedContacts.first != contact {
                    selectedContacts.removeAll()
                    selectedContacts.append(contact)
                } else {
                    selectedContacts.removeAll()
                }
                tableView.reloadData()
            }
            delegate?.contactsController(self, didSelect: selectedContacts)
        }
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let selectedContact = userContactList?[indexPath.row] {
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
        return delegate == nil
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
        self.addCustomContactId(title: "Please enter custom contact details", message: "")
    }

    func addCustomContactId(title: String, message: String) {
        let contactName = Self.randomFakeName()
        DispatchQueue.main.async {
            self.editContact(title: title, index: 0, message: message, contactId: UUID().uuidString, contactName: contactName, contactEmail: Self.fakeMail(with: contactName), isNewContact: true)
        }
    }

    func getInputFromAlertWithTextField(title: String? = nil,
                                        message: String? = nil,
                                        keyboardType: UIKeyboardType? = .asciiCapable,
                                        textFieldDefaultValue: String?,
                                        name: String? = randomFakeName(),
                                        email: String? = nil,
                                        handler: ((UIAlertAction, UITextField?, String, String) -> Void)? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let alert = UIAlertController(title: title,
                message: message,
                preferredStyle: .alert)
            var textObserver: NSObjectProtocol?

            let email = email ?? Self.fakeMail(with: name)

            let okAction = UIAlertAction(title: MASDKLocale.localize(.ok), style: .default) { (action) in
                if !alert.textFields![0].text!.isEmpty {
                    handler?(action, alert.textFields?.first, alert.textFields?[1].text ?? "", alert.textFields?[2].text ?? "")
                } else {
                    handler?(action, nil, "", "")
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
                textField.placeholder = NSLocalizedString("contact.id", comment: "")
                textField.clearButtonMode = .whileEditing
            }

            alert.addTextField { (textField) in
                textField.text = name
                textField.placeholder = NSLocalizedString("contact.name", comment: "")
                textField.clearButtonMode = .whileEditing
            }
            alert.addTextField { (textField) in
                textField.text = email
                textField.placeholder = NSLocalizedString("contact.email", comment: "")
                textField.clearButtonMode = .whileEditing
            }
            okAction.isEnabled = !(textFieldDefaultValue?.isEmpty ?? true)
            alert.addAction(UIAlertAction(title: MASDKLocale.localize(.cancel), style: .cancel, handler: nil))
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }

    func editContact(title: String, index: Int, message: String? = "", contactId: String? = "", contactName: String? = "", contactEmail: String? = "", isNewContact: Bool? = false) {
        DispatchQueue.main.async {
            self.getInputFromAlertWithTextField(title: title, message: message, textFieldDefaultValue: contactId, name: contactName, email: contactEmail) { (_, textField, name, email) in
                self.validateAllValues(index: index, contactId: contactId, textField: textField, name: name, email: email, isNewContact: isNewContact)
            }
        }
    }

    func validateAllValues(index: Int, contactId: String?, textField: UITextField?, name: String, email: String, isNewContact: Bool? = false) {
        if let contactIdTextField = textField {
            if contactIdTextField.isTextFieldEmpty() {
                self.editContact(title: "Invalid Contact ID, please try again",
                                 index: index,
                                 contactId: contactIdTextField.text,
                                 contactName: name,
                                 contactEmail: email, isNewContact: isNewContact)
            } else if name.isValueEmpty() {
                self.editContact(title: "Invalid Name, please try again",
                                 index: index,
                                 contactId: contactIdTextField.text,
                                 contactName: name,
                                 contactEmail: email, isNewContact: isNewContact)
            } else if email.isValueEmpty() || !email.isValidEmail() {
                self.editContact(title: "Invalid Email ID, please try again",
                                 index: index,
                                 contactId: contactIdTextField.text,
                                 contactName: name,
                                 contactEmail: email, isNewContact: isNewContact)
            } else {
                if let contactID =  textField?.text {
                    if isNewContact ?? false {
                        self.userContactList?.append(MAContact(id: contactID,
                                                               name: name,
                                                               email: email))
                        updateContactList(list: self.userContactList)
                        self.tableView.reloadData()
                    } else {
                        self.userContactList?[index] = MAContact(id: contactID, name: name, email: email)
                        updateContactList(list: self.userContactList)
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }

    class func fakeMail(with name: String?) -> String {
        name != nil ? name!.replacingOccurrences(of: " ", with: ".", options: .literal, range: nil).lowercased() + "@example.com" : ""
    }

    class func randomFakeName() -> String {
        randomFakeFirstName() + " " + randomFakeLastName()
    }

    class func randomFakeFirstName() -> String {
        let firstNameList = ["Yvonne", "Jamie", "Leticia", "Priscilla", "Sidney", "Nancy", "Edmund", "Bill", "Megan"]
        return firstNameList.randomElement()!
    }

    class func randomFakeLastName() -> String {
        let lastNameList = ["Andrews", "Casey", "Gross", "Lane", "Thomas", "Patrick", "Strickland", "Nicolas", "Freeman"]
        return lastNameList.randomElement()!
    }
}
