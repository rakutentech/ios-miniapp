import MiniApp

extension ViewController {
    func fetchAppList() {
        let silent = self.decodeResponse?.count ?? 0 > 0
        showProgressIndicator(silently: silent) {
            MiniApp.shared(with: Config.getCurrent()).list { (result) in
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                }
                switch result {
                case .success(let responseData):
                    DispatchQueue.main.async {
                        self.decodeResponse = responseData
                        self.tableView.reloadData()
                        self.dismissProgressIndicator()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    self.displayAlert(title: NSLocalizedString("error_title", comment: ""), message: NSLocalizedString("error_list_message", comment: ""), dismissController: true)
                }
            }
        }
    }

    func fetchAppInfo(for miniAppID: String) {
        self.showProgressIndicator {
            MiniApp.shared(with: Config.getCurrent()).info(miniAppId: miniAppID) { (result) in
                self.dismissProgressIndicator {
                    switch result {
                    case .success(let responseData):
                        self.currentMiniAppInfo = responseData
                        self.performSegue(withIdentifier: "DisplayMiniApp", sender: nil)
                    case .failure(let error):
                        print(error.localizedDescription)
                        self.displayAlert(
                            title: NSLocalizedString("error_title", comment: ""),
                            message: NSLocalizedString("error_single_message", comment: ""),
                            dismissController: true)
                    }
                }
            }
        }
    }
}
