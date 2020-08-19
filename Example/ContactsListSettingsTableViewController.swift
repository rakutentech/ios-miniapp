import UIKit
import MiniApp

class ContactsListSettingsTableViewController: UITableViewController {

    var userContactList: [String?] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareRandomContactList()
        self.tableView.separatorStyle = .singleLine
        self.tableView.tableFooterView = UIView(frame: .zero)
    }

    func prepareRandomContactList() {
        for _ in 1...10 {
            userContactList.append(UUID().uuidString)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell? ?? UITableViewCell()
        if userContactList.indices.contains(indexPath.row) {
            cell.textLabel?.text = userContactList[indexPath.row]
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userContactList.count
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if userContactList.indices.contains(indexPath.row) {
                userContactList.remove(at: indexPath.row)
                self.tableView.reloadData()
            }
        }
    }

    @IBAction func addContact() {
        userContactList.append(UUID().uuidString)
        self.tableView.reloadData()
    }
}
