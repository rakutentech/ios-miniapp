import UIKit
import MiniApp

class QueryParamViewController: UITableViewController {

    @IBOutlet weak var queryStringTextfield: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.queryStringTextfield.text = getQueryParam()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        guard let queryString = queryStringTextfield.text?.trimTrailingWhitespaces() else {
            return
        }
        _ = saveQueryParam(queryParam: queryString)
    }
}
