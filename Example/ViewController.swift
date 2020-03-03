import UIKit
import MiniApp

class ViewController: UITableViewController {

    var decodeResponse: [MiniAppInfo]?
    var currentMiniAppInfo: MiniAppInfo?

    override func viewDidLoad() {
        super.viewDidLoad()
        showProgressIndicator()

        MiniApp.list { (result) in
            switch result {
            case .success(let responseData):
                self.decodeResponse = responseData
                self.tableView.reloadData()
                self.dismissProgressIndicator()
            case .failure(let error):
                print(error.localizedDescription)
                self.displayErrorAlert(title: "Error", message: "Couldn't retrieve Mini App list, please try again later", dismissController: false)
            }
        }
    }

    @IBAction func actionShowMiniAppById() {
        let alert = UIAlertController(title: "Please enter Mini App ID",
                                      message: nil,
                                      preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.keyboardType = .asciiCapable
        }

        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            self.showProgressIndicator()
            if let textField = alert.textFields?.first, let miniAppID = textField.text, miniAppID.count > 0 {
                MiniApp.info(miniAppId: miniAppID) { (result) in
                    switch result {
                    case .success(let responseData):
                        self.currentMiniAppInfo = responseData
                        self.performSegue(withIdentifier: "DisplayMiniApp", sender: nil)
                    case .failure(let error):
                        print(error.localizedDescription)
                        self.displayErrorAlert(title: "Error", message: "Couldn't retrieve Mini App info, please try again later", dismissController: false)
                    }
                    self.dismissProgressIndicator()
                }
            } else {
                self.dismissProgressIndicator()
                self.displayErrorAlert(title: "Error", message: "Incorrect Mini App ID, please try again", dismissController: false)
            }
        }
        alert.addAction(okAction)

        self.present(alert, animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return decodeResponse?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MiniAppCell", for: indexPath)

        let miniAppDetail = self.decodeResponse?[indexPath.row]
        cell.textLabel?.text = miniAppDetail?.displayName
        cell.imageView?.image = UIImage(named: "image_placeholder")
        cell.imageView?.loadImageURL(url: miniAppDetail!.icon)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DisplayMiniApp" {
            if let indexPath = self.tableView.indexPathForSelectedRow?.row {
                currentMiniAppInfo = decodeResponse?[indexPath]
            }

            guard let miniAppInfo = self.currentMiniAppInfo else {
                self.displayErrorAlert(title: "Error", message: "Couldn't retrieve Mini App, please try again later", dismissController: false)
                return
            }

            let displayController = segue.destination as? DisplayController
            displayController?.miniAppInfo = miniAppInfo
            self.currentMiniAppInfo = nil
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
