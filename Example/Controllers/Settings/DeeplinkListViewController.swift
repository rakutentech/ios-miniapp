import UIKit
import MiniApp

class DeeplinkListViewController: UITableViewController {

    var bannerMessage: CGFloat = 0
    var deepLinkList: [String]? = []

    override func viewDidLoad() {
        super.viewDidLoad()
        deepLinkList = getDeepLinksList()
        tableView.separatorStyle = .singleLine
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: bannerMessage))
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell? ?? UITableViewCell()
        if let deepLinkList = deepLinkList, deepLinkList.indices.contains(indexPath.row) {
            cell.textLabel?.text = deepLinkList[indexPath.row]
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let deeplinkDomain = deepLinkList?[indexPath.row] {
            editDeeplinkDomain(title: "Edit Deeplink",
                               index: indexPath.row, message: "", deeplinkDomain: deeplinkDomain)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        deepLinkList?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if deepLinkList?.indices.contains(indexPath.row) ?? false {
                deepLinkList?.remove(at: indexPath.row)
                updateDeeplinkList(list: deepLinkList)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }

    @IBAction func addDeepLink() {
        self.addDeepLinkDomain(title: "Please enter valid deep link", message: "")
    }

    func addDeepLinkDomain(title: String, message: String) {
        DispatchQueue.main.async {
            self.editDeeplinkDomain(title: title, index: 0, message: message, deeplinkDomain: "miniappdemo", isNewDomain: true)
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
                textField.clearButtonMode = .whileEditing
            }
            okAction.isEnabled = !(textFieldDefaultValue?.isEmpty ?? true)
            alert.addAction(UIAlertAction(title: MASDKLocale.localize(.cancel), style: .cancel, handler: nil))
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }

    func editDeeplinkDomain(title: String, index: Int, message: String? = "", deeplinkDomain: String? = "", isNewDomain: Bool? = false) {
        DispatchQueue.main.async {
            self.getInputFromAlertWithTextField(title: title, message: message, textFieldDefaultValue: deeplinkDomain) { (_, textField)  in
                self.validateAllValues(index: index, deeplinkDomain: deeplinkDomain, textField: textField, isNewDomain: isNewDomain)
            }
        }
    }

    func validateAllValues(index: Int, deeplinkDomain: String?, textField: UITextField?, isNewDomain: Bool? = false) {
        if let deeplinkTextfield = textField {
            guard let deeplinkDomainText =  textField?.text, !deeplinkTextfield.isTextFieldEmpty() else {
                self.editDeeplinkDomain(title: "Invalid Deeplink, please try again",
                                 index: index,
                                 deeplinkDomain: deeplinkTextfield.text,
                                 isNewDomain: isNewDomain)
                return
            }
            if isNewDomain ?? false {
                self.deepLinkList?.append(deeplinkDomainText)
                updateDeeplinkList(list: deepLinkList)
                self.tableView.reloadData()
            } else {
                self.deepLinkList?[index] = deeplinkDomainText
                updateDeeplinkList(list: deepLinkList)
                self.tableView.reloadData()
            }
        }
    }
}
