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
                self.displayAlert(title: "Error", message: "Couldn't retrieve Mini App list, please try again later")
            }
        }
    }

    func decodeListingResponse(with dataResponse: Data?) -> [MiniAppInfo]? {
        do {
            return try JSONDecoder().decode(Array<MiniAppInfo>.self, from: dataResponse!)
        } catch let error {
            print("Decoding Failed with Error: ", error)
            return nil
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

    func displayAlert(title: String, message: String) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            })
        }
    }

    func showProgressIndicator() {
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating()

        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
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
