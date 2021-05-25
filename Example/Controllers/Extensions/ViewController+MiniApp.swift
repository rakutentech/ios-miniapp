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
                            title: MASDKLocale.localize("miniapp.sdk.ios.error.title"),
                            message: MASDKLocale.localize("miniapp.sdk.ios.error.message.list"),
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
                        message = MASDKLocale.localize(.noPublishedVersion)
                    case .miniAppNotFound:
                        message = MASDKLocale.localize(.miniappIdNotFound)
                    default:
                        message = MASDKLocale.localize("miniapp.sdk.ios.error.message.single")
                    }
                    print(error.localizedDescription)
                    self.dismissProgressIndicator {
                        self.fetchMiniAppUsingId(title: MASDKLocale.localize("miniapp.sdk.ios.error.title"), message: message)
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
                self.displayAlert(title: MASDKLocale.localize("miniapp.sdk.ios.error.title"), message: MASDKLocale.localize("miniapp.sdk.ios.error.message.miniapp"), dismissController: true)
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
                self.fetchMiniAppUsingId(title: MASDKLocale.localize("input_valid_miniapp_title"), message: NSLocalizedString("miniapp.sdk.ios.error.message.invalid_miniapp_id", comment: ""))
            }
        }
    }

    func checkSDKErrorAndDisplay(error: MASDKError) {
            var errorMessage: String = ""
            switch error {
            case .metaDataFailure:
                guard let miniAppInfo = currentMiniAppInfo else {
                    errorMessage =  String(format: MASDKLocale.localize("miniapp.sdk.ios.error.message.metadata"), MASDKLocale.localize(.downloadFailed))
                    return
                }
                self.showFirstTimeLaunchScreen(miniAppInfo: miniAppInfo)
            default:
                errorMessage = MASDKLocale.localize(.downloadFailed)
            }
            self.displayAlert(title: MASDKLocale.localize("miniapp.sdk.ios.error.title"), message: errorMessage, dismissController: true) { _ in
                self.fetchAppList(inBackground: true)
            }
        }
}
