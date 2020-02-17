import UIKit
import MiniApp

class ViewController: UITableViewController {

    var decodeResponse: [MiniAppInfo]?

    override func viewDidLoad() {
        super.viewDidLoad()
        showProgressIndicator()

        MiniApp.list { (result) in
            switch result {
            case .success(let responseData):
                self.decodeResponse = responseData
                self.tableView.reloadData()
                self.dismiss(animated: false, completion: nil)
            case .failure(let error):
                print(error.localizedDescription)
                self.displayErrorAlert(title: "Error", message: "Couldn't retrieve Mini App list, please try again later", dimissController: false)
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return decodeResponse?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MiniAppCell", for: indexPath)

        let miniAppDetail = self.decodeResponse?[indexPath.row]
        cell.textLabel?.text = miniAppDetail?.name
        cell.detailTextLabel?.text = miniAppDetail?.description
        cell.imageView?.image = UIImage(named: "image_placeholder")
        cell.imageView?.loadImageURL(url: miniAppDetail!.icon)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if segue.identifier == "DisplayMiniApp" {
        guard let indexPath = self.tableView.indexPathForSelectedRow?.row else {
            self.displayErrorAlert(title: "Error", message: "Couldn't retrieve Mini App, please try again later", dimissController: false)
            return
        }
        let displayController = segue.destination as? DisplayController
        displayController?.miniAppInfo = decodeResponse?[indexPath]
       }
    }
}

extension UIImageView {
    func loadImageURL(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
