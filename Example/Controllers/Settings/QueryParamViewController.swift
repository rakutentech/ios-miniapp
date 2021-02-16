import UIKit
import MiniApp

class QueryParamViewController: UITableViewController {

    @IBOutlet weak var queryStringTextfield: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        queryStringTextfield.text = getQueryParam()
    }

    @IBAction func actionSaveParam(_ sender: UIBarButtonItem) {
        guard let queryString = queryStringTextfield.text?.trimTrailingWhitespaces() else {
            return
        }

        if URL(string: "https://www.rakuten.co.jp"+queryString) == nil {
            displayAlert(title: NSLocalizedString("Invalid string", comment: ""), message: NSLocalizedString("The query parameter string is bad formatted or contains invalid characters", comment: ""))
            return
        }

        if saveQueryParam(queryParam: queryString) {
            navigationController?.popViewController(animated: true)
        } else {
            displayAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Error while saving query parameters", comment: ""))
        }
    }
}
