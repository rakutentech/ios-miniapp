import UIKit
import MiniApp

class DeeplinkListViewController: UITableViewController {

    var bannerMessage: CGFloat = 0
    var deepLinkList: [String]? = []
    var selectedContacts = [MAContact]()
    var allowMultipleSelection = true

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .singleLine
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: bannerMessage))
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell? ?? UITableViewCell()
        if let deepLinkList = deepLinkList, deepLinkList.indices.contains(indexPath.row) {
            cell.detailTextLabel?.numberOfLines = 3
            let titleSize = cell.textLabel?.font.pointSize ?? 12
            cell.textLabel?.text = deepLinkList[indexPath.row]
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

//    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        if let selectedContact = deepLinkList?[indexPath.row] {
//            selectedContacts.removeAll(where: { contact in
//                contact == selectedContact
//            })
//            tableView.reloadRows(at: [indexPath], with: .automatic)
//        }
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        deepLinkList?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if deepLinkList?.indices.contains(indexPath.row) ?? false {
                deepLinkList?.remove(at: indexPath.row)
//                updateContactList(list: self.deepLinkList)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }

    @IBAction func addDeepLink() {
        self.addDeepLinkDomain(title: "Please enter custom deep link", message: "")
    }

    func addDeepLinkDomain(title: String, message: String) {
        DispatchQueue.main.async {
            self.editContact(title: title, index: 0, message: message, deeplinkDomain: "miniappdemo", isNewDomain: true)
        }
    }

    func getInputFromAlertWithTextField(title: String? = nil,
                                        message: String? = nil,
                                        keyboardType: UIKeyboardType? = .asciiCapable,
                                        textFieldDefaultValue: String?,
                                        handler: ((UIAlertAction, UITextField?) -> Void)? = nil) {
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
                textField.placeholder = NSLocalizedString("contact.id", comment: "")
                textField.clearButtonMode = .whileEditing
            }
            okAction.isEnabled = !(textFieldDefaultValue?.isEmpty ?? true)
            alert.addAction(UIAlertAction(title: MASDKLocale.localize(.cancel), style: .cancel, handler: nil))
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }

    func editContact(title: String, index: Int, message: String? = "", deeplinkDomain: String? = "", isNewDomain: Bool? = false) {
        DispatchQueue.main.async {
            self.getInputFromAlertWithTextField(title: title, message: message, textFieldDefaultValue: deeplinkDomain) { (_, textField)  in
//                self.validateAllValues(index: index, deeplinkDomain: deeplinkDomain, textField: textField, isNewDomain: isNewDomain)
            }
        }
    }

//    func validateAllValues(index: Int, deeplinkDomain: String?, textField: UITextField?, isNewDomain: Bool? = false) {
//        if let contactIdTextField = textField {
//            if contactIdTextField.isTextFieldEmpty() {
//                self.editContact(title: "Invalid Contact ID, please try again",
//                                 index: index,
//                                 deeplinkDomain: contactIdTextField.text,
//                                 isNewDomain: isNewDomain)
//            } else {
//                if let deeplinkDomain =  textField?.text {
//                    if isNewDomain ?? false {
//                        self.deepLinkList?.append(MAContact(id: deeplinkDomain))
//                        updateContactList(list: self.deepLinkList)
//                        self.tableView.reloadData()
//                    } else {
//                        self.deepLinkList?[index] = MAContact(id: deeplinkDomain)
//                        updateContactList(list: self.deepLinkList)
//                        self.tableView.reloadData()
//                    }
//                }
//            }
//        }
//    }
}
