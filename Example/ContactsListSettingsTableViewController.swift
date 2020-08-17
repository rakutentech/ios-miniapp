import UIKit
import MiniApp

class ContactsListSettingsTableViewController: UITableViewController {

    var userContactList: [String?: Any] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = .singleLine
        self.tableView.tableFooterView = UIView(frame: .zero)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell? ?? UITableViewCell()
        cell.textLabel?.text = "User Contact - " + String(indexPath.row + 1)
        userContactList[cell.textLabel?.text] = UUID().uuidString
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
}
