import MiniApp

extension ViewController: MiniAppMessageProtocol {
    func getUniqueId() -> String {
        guard let deviceId = UIDevice.current.identifierForVendor?.uuidString else {
            return ""
        }
        return deviceId
    }
}

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
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    self.displayAlert(title: NSLocalizedString("error_title", comment: ""), message: NSLocalizedString("error_list_message", comment: ""), dismissController: true)
                }
                self.dismissProgressIndicator()
            }
        }
    }

    func fetchAppInfo(for miniAppID: String) {
        self.showProgressIndicator {
            MiniApp.shared(with: Config.getCurrent()).info(miniAppId: miniAppID) { (result) in
                switch result {
                case .success(let responseData):
                    self.currentMiniAppInfo = responseData
                    self.fetchMiniApp(for: responseData)
                case .failure(let error):
                    print(error.localizedDescription)
                    self.dismissProgressIndicator {
                        self.fetchMiniAppUsingId(title: NSLocalizedString("error_title", comment: ""), message: NSLocalizedString("error_single_message", comment: ""))
                    }
                }
                self.dismissProgressIndicator()
            }
        }
    }

    func fetchMiniApp(for appInfo: MiniAppInfo) {
        MiniApp.shared(with: Config.getCurrent()).create(appInfo: appInfo, completionHandler: { (result) in
            switch result {
            case .success(let miniAppDisplay):
                self.dismissProgressIndicator {
                    self.currentMiniAppView = miniAppDisplay
                    self.performSegue(withIdentifier: "DisplayMiniApp", sender: nil)
                }
            case .failure(let error):
                self.displayAlert(title: NSLocalizedString("error_title", comment: ""), message: NSLocalizedString("error_miniapp_download_message", comment: ""), dismissController: true) { _ in
                    self.fetchAppList()
                }
                print("Errored: ", error.localizedDescription)
            }
        }, messageInterface: self)
    }

    func fetchMiniAppUsingId(title: String? = nil, message: String? = nil) {
        self.displayTextFieldAlert(title: title, message: message) { (_, textField) in
            if let textField = textField, let miniAppID = textField.text, miniAppID.count > 0 {
                self.fetchAppInfo(for: miniAppID)
            } else {
                self.fetchMiniAppUsingId(title: NSLocalizedString("error_invalid_miniapp_id", comment: ""), message: NSLocalizedString("input_valid_miniapp_title", comment: ""))
            }
        }
    }
}
