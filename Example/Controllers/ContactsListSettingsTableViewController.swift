import UIKit
import MiniApp

class ContactsListSettingsTableViewController: UITableViewController {

    var userContactList: [MAContact]? = []
    internal static let contactName = "Example Name", contactEmail = "name@example.com"

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareRandomContactList()
        self.tableView.separatorStyle = .singleLine
        self.tableView.tableFooterView = UIView(frame: .zero)
    }

    func prepareRandomContactList() {
        userContactList = getContactList()
        if userContactList == nil {
            userContactList = []
            for _ in 1...10 {
                userContactList?.append(
                    MAContact(id: UUID().uuidString,
                              name: ContactsListSettingsTableViewController.contactName,
                              email: ContactsListSettingsTableViewController.contactEmail))
            }
            updateContactList(list: self.userContactList)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell? ?? UITableViewCell()
        if userContactList?.indices.contains(indexPath.row) ?? false {
            cell.textLabel?.text = userContactList?[indexPath.row].id
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userContactList?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
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
            self.getInputFromAlertWithTextField(title: title, message: message) { (_, textField) in
                if let textField = textField, let contactId = textField.text, contactId.count > 0, !contactId.trimTrailingWhitespaces().isEmpty {
                    self.userContactList?.append(MAContact(id: contactId,
                                                           name: ContactsListSettingsTableViewController.contactName,
                                                           email: ContactsListSettingsTableViewController.contactEmail))
                    updateContactList(list: self.userContactList)
                    self.tableView.reloadData()
                } else {
                    self.addCustomContactId(title: "Invalid Contact ID, please try again", message: "Enter valid contact and select Ok")
                }
            }
        }
    }

    func getInputFromAlertWithTextField(title: String? = nil, message: String? = nil, keyboardType: UIKeyboardType? = .asciiCapable, handler: ((UIAlertAction, UITextField?) -> Void)? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let alert = UIAlertController(title: title,
                message: message,
                preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.delegate = self
                if let type = keyboardType {
                    textField.keyboardType = type
                }
            }

            let okAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { (action) in
                if !alert.textFields![0].text!.isEmpty {
                    handler?(action, alert.textFields?.first)
                } else {
                    handler?(action, nil)
                }
            }
            okAction.isEnabled = false
            alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
}
