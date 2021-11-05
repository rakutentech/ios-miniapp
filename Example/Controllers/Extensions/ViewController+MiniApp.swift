import MiniApp

extension ViewController: MiniAppNavigationDelegate {
    func miniAppNavigationCanGo(back: Bool, forward: Bool) {
        guard let miniAppDisplayController = UINavigationController.topViewController() as? MiniAppViewController else {
            guard let miniAppDisplayController = UINavigationController.topViewController() as? DisplayController else {
                return
            }
            return miniAppDisplayController.refreshNavigationBarButtons(backButtonEnabled: back, forwardButtonEnabled: forward)
        }
        miniAppDisplayController.refreshNavigationBarButtons(backButtonEnabled: back, forwardButtonEnabled: forward)
    }

    func miniAppNavigation(shouldOpen url: URL,
                           with responseHandler: @escaping MiniAppNavigationResponseHandler,
                           onClose closeHandler: MiniAppNavigationResponseHandler?) {
        if url.absoluteString.starts(with: "data:") {
            // currently js sdk is passing no base64 data type
            let base64String = url.absoluteString.components(separatedBy: ",").last ?? ""
            guard let base64Data = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) else { return }
            var activityItem: Any?
            if let image = UIImage(data: base64Data) {
                activityItem = image
            } else {
                activityItem = base64Data
            }
            guard let wrappedActivityItem = activityItem else { return }
            let activityViewController = UIActivityViewController(activityItems: [wrappedActivityItem], applicationActivities: nil)
            presentedViewController?.present(activityViewController, animated: true, completion: nil)
        } else {
            if !isDeepLinkURL(url: url) {
                MiniAppExternalWebViewController.presentModally(url: url,
                                                                externalLinkResponseHandler: responseHandler,
                                                                customMiniAppURL: nil,
                                                                onCloseHandler: closeHandler)
            }
        }
    }

    func isDeepLinkURL(url: URL) -> Bool {
        if getDeepLinksList().contains(where: url.absoluteString.hasPrefix) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return true
        }
        return false
    }

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
                    self.showMiniApp(for: responseData)
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

    func showMiniApp(for appInfo: MiniAppInfo) {
        // replacing the manifest fails
        self.dismissProgressIndicator { [weak self] in
            guard let self = self else { return }
            let uiparams = MiniAppUIParams(
                title: appInfo.displayName ?? "MiniApp",
                miniAppId: appInfo.id,
                miniAppVersion: appInfo.version.versionId,
                config: Config.current(),
                messageInterface: self,
                navigationInterface: self,
                queryParams: getQueryParam(),
                adsDisplayer: self.adsDisplayer
            )
            MiniAppUI
                .shared()
                .launch(base: self, params: uiparams, delegate: self)
        }
    }

    func loadMiniAppUsingURL(_ url: URL) {
        let miniAppDisplay = MiniApp.shared(with: Config.current(), navigationSettings: Config.getNavConfig(delegate: self)).create(
            url: url,
            queryParams: getQueryParam(),
            errorHandler: { error in
                self.displayAlert(title: MASDKLocale.localize("miniapp.sdk.ios.error.title"), message: MASDKLocale.localize("miniapp.sdk.ios.error.message.miniapp"), dismissController: true)
                log("loadMiniAppUsingURL(_ url: \(url.absoluteString)) Errored: " + error.localizedDescription)
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
        switch error {
        case .metaDataFailure:
            metaDataFailure()
        case .invalidSignature:
            self.displayAlert(title: MASDKLocale.localize("miniapp.sdk.ios.error.title"), message: MASDKLocale.localize(.signatureFailed), dismissController: true) { _ in
                self.fetchAppList(inBackground: true)
            }
        default:
            self.displayAlert(title: MASDKLocale.localize("miniapp.sdk.ios.error.title"), message: MASDKLocale.localize(.downloadFailed), dismissController: true) { _ in
                self.fetchAppList(inBackground: true)
            }
        }
    }

    // We need to dismiss current Mini App controller to show First time screen.
    // This is due to the recent change on how we display Miniapp, MiniAppUI.shared().launch()
    func metaDataFailure() {
        DispatchQueue.main.async {
            self.dismiss(animated: true) {
                guard let miniAppInfo = self.currentMiniAppInfo else {
                    return self.displayAlert(title: MASDKLocale.localize("miniapp.sdk.ios.error.title"),
                                             message: String(format: MASDKLocale.localize("miniapp.sdk.ios.error.message.metadata"), MASDKLocale.localize(.downloadFailed)),
                                             dismissController: true) { _ in
                        self.fetchAppList(inBackground: true)
                    }
                }
                self.fetchMiniAppMetaData(miniAppInfo: miniAppInfo, config: Config.current())
            }
        }
    }
}

extension ViewController: MiniAppUIDelegate {
    func onClose() {
        dismiss(animated: true, completion: nil)
    }

    func miniApp(_ viewController: MiniAppViewController, didLoadWith error: MASDKError?) {
        guard let error = error else { return }
        print("Errored: ", error.localizedDescription)
        checkSDKErrorAndDisplay(error: error)
    }
}
