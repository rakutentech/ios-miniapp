import MiniApp

extension ViewController: MiniAppNavigationDelegate {
    func fetchAppList(inBackground: Bool) {
        showProgressIndicator(silently: inBackground) {
            MiniApp.shared(with: Config.current(), navigationSettings: Config.getNavConfig(delegate: self)).list { (result) in
                DispatchQueue.main.async {
                    self.tableView.refreshControl?.endRefreshing()
                }
                switch result {
                case .success(let responseData):
                    DispatchQueue.main.async {
                        self.unfilteredResults = responseData
                        self.tableView.reloadData()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    if !inBackground {
                        self.displayAlert(
                            title: MiniAppLocalizable.localize("miniapp.sdk.error.title"),
                            message: MiniAppLocalizable.localize("miniapp.sdk.error.message.list"),
                            dismissController: true)
                    }
                }
                if !inBackground {
                    self.dismissProgressIndicator()
                }
            }
        }
    }

    func fetchAppInfo(for miniAppID: String) {
        self.showProgressIndicator {
            MiniApp.shared(with: Config.current(), navigationSettings: Config.getNavConfig(delegate: self)).info(miniAppId: miniAppID) { (result) in
                switch result {
                case .success(let responseData):
                    self.currentMiniAppInfo = responseData
                    self.fetchMiniApp(for: responseData)
                case .failure(let error):
                    var message: String
                    switch error {
                    case .noPublishedVersion:
                        message = MiniAppLocalizable.localize(.noPublishedVersion)
                    case .miniAppNotFound:
                        message = MiniAppLocalizable.localize(.miniappIdNotFound)
                    default:
                        message = MiniAppLocalizable.localize("miniapp.sdk.error.message.single")
                    }
                    print(error.localizedDescription)
                    self.dismissProgressIndicator {
                        self.fetchMiniAppUsingId(title: MiniAppLocalizable.localize("miniapp.sdk.error.title"), message: message)
                    }
                }
            }
        }
    }

    func fetchMiniApp(for appInfo: MiniAppInfo) {
        MiniApp.shared(with: Config.current(),
                       navigationSettings: Config.getNavConfig(delegate: self))
            .create(appId: appInfo.id,
                    version: appInfo.version.versionId,
                    queryParams: getQueryParam(),
                    completionHandler: { (result) in
            switch result {
            case .success(let miniAppDisplay):
                self.dismissProgressIndicator {
                    self.currentMiniAppView = miniAppDisplay
                    self.performSegue(withIdentifier: "DisplayMiniApp", sender: nil)
                }
            case .failure(let error):
                self.checkSDKErrorAndDisplay(error: error)
                print("Errored: ", error.localizedDescription)
            }
        }, messageInterface: self, adsDisplayer: adsDisplayer)
    }

    func loadMiniAppUsingURL(_ url: URL) {
        let miniAppDisplay = MiniApp.shared(with: Config.current(), navigationSettings: Config.getNavConfig(delegate: self)).create(
            url: url,
            queryParams: getQueryParam(),
            errorHandler: { error in
                self.displayAlert(title: MiniAppLocalizable.localize("miniapp.sdk.error.title"), message: MiniAppLocalizable.localize("miniapp.sdk.error.message.miniapp"), dismissController: true)
                print("Errored: ", error.localizedDescription)
            }, messageInterface: self, adsDisplayer: adsDisplayer)

        currentMiniAppView = miniAppDisplay
        performSegue(withIdentifier: "DisplayMiniApp", sender: nil)
    }

    func fetchMiniAppUsingId(title: String? = nil, message: String? = nil) {
        self.displayTextFieldAlert(title: title, message: message) { (_, textField) in
            if let textField = textField, let miniAppID = textField.text, miniAppID.count > 0 {
                self.fetchAppInfo(for: miniAppID)
            } else {
                self.fetchMiniAppUsingId(title: MiniAppLocalizable.localize("input_valid_miniapp_title"), message: NSLocalizedString("miniapp.sdk.error.message.invalid_miniapp_id", comment: ""))
            }
        }
    }

    func checkSDKErrorAndDisplay(error: MASDKError) {
            var errorMessage: String = ""
            switch error {
            case .metaDataFailure:
                guard let miniAppInfo = currentMiniAppInfo else {
                    errorMessage =  MiniAppLocalizable.localize("miniapp.sdk.error.message.metadata", MiniAppLocalizable.localize(.downloadFailed))
                    return
                }
                self.showFirstTimeLaunchScreen(miniAppInfo: miniAppInfo)
            default:
                errorMessage = MiniAppLocalizable.localize(.downloadFailed)
            }
            self.displayAlert(title: MiniAppLocalizable.localize("miniapp.sdk.error.title"), message: errorMessage, dismissController: true) { _ in
                self.fetchAppList(inBackground: true)
            }
        }
}
