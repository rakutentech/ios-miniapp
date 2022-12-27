import Foundation
import MiniApp
import Combine

@MainActor
class MiniAppSettingsViewModel: ObservableObject {

    let store = MiniAppStore.shared

    @Published var indexedMiniAppInfoList: [String: [MiniAppInfo]] = [:]
    @Published var state: State = .none

    @Published var listConfigI = ListConfiguration(listType: .listI)
    @Published var listConfigII = ListConfiguration(listType: .listII)

    @Published var selectedListConfig: ListType = .listI
    var listConfig: ListConfiguration {
        get {
            switch selectedListConfig {
            case .listI:
                return listConfigI
            case .listII:
                return listConfigII
            }
        }
        set {
            switch selectedListConfig {
            case .listI:
                listConfigI = newValue
            case .listII:
                listConfigII = newValue
            }
        }
    }

    var bag = Set<AnyCancellable>()

    func getBuildVersionText() -> String {
        var versionText = ""
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionText.append("Build Version: \(version) - ")
        }
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            versionText.append("(\(build))")
        }
        return versionText
    }

    func save(completion: (() -> Void)? = nil) {

        state = .loading

        loadAndPersistList(listConfig: listConfigI) { [weak self] listErrorI in
            guard let self = self else { return }
            if let listErrorI = listErrorI {
                self.listConfigI.error = listErrorI
                self.store.miniAppInfoListError = listErrorI
            } else {
                self.listConfigI.error = nil
                self.store.miniAppInfoListError = nil
            }
            self.loadAndPersistList(listConfig: self.listConfigII) { listErrorII in
                if let listErrorII = listErrorII {
                    self.listConfigII.error = listErrorII
                    self.store.miniAppInfoList2Error = listErrorII
                } else {
                    self.listConfigII.error = nil
                    self.store.miniAppInfoList2Error = nil
                }
                if listErrorI == nil && listErrorII == nil {
                    self.state = .success
                } else {
                    if let listErrorI = listErrorI {
                        self.state = .error(listErrorI)
                    } else if let listErrorII = listErrorII {
                        self.state = .error(listErrorII)
                    }
                }
            }
            if self.saveTokenDetails(accessToken: "ACCESS_TOKEN", date: Date()) {
                print("AccessToken is now set to default value \"ACCESS_TOKEN\"")
            }
        }
    }

    func loadAndPersistList(listConfig: ListConfiguration, completion: ((Error?) -> Void)? = nil) {
        let listSdkConfig = listConfig.sdkConfig
        MiniApp
            .shared(with: listSdkConfig)
            .list { (result) in
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(750)) {
                    switch result {
                    case let .success(infos):
                        if !self.store.miniAppSetupCompleted {
                            self.store.miniAppSetupCompleted = true
                        }
                        listConfig.persist()
                        self.store.update(type: listConfig.listType, infos: infos)
                        completion?(nil)
                    case .failure(let error):
                        self.store.update(type: listConfig.listType, infos: [])
                        completion?(error)
                    }
                }
            }
    }

    // MARK: - General

    func getDeepLinkList() -> [String] {
        return getDeepLinksList()
    }

    func saveDeepLinkList(list: [String]) {
        setDeepLinksList(deeplinksList: list)
    }

    // MARK: - QA

    func getSecureStorageMaxSize() -> String {
        store.getSecureStorageLimitString()
    }

    func clearSecureStorages() {
        store.clearSecureStorages()
    }

    func clearSecureStorage(appId: String) {
        store.clearSecureStorage(appId: appId)
    }

    func setSecureStorageLimit(maxSize: String) -> Result<String, MiniAppStore.StoreError> {
        store.setSecureStorageLimit(maxSize: maxSize)
    }

    // MARK: - Profile

    func getContacts() -> [MAContact] {
        getContactList() ?? []
    }

    func saveContactList(contacts: [MAContact]) {
        updateContactList(list: contacts)
    }

    func setUserDetails(name: String?, imageUrl: String?) -> Bool {
        return setProfileSettings(userDisplayName: name, profileImageURI: imageUrl)
    }

    func getUserDetails() -> UserProfileModel? {
        return getProfileSettings()
    }

    func createRandomContact() -> MAContact {
        let fakeName = MiniAppStore.randomFakeName()
        return MAContact(id: UUID().uuidString, name: fakeName, email: MiniAppStore.fakeMail(with: fakeName))
    }

    // MARK: - Access Token
    func getAccessTokenBehavior() -> MiniAppSettingsAccessTokenView.ErrorBehavior {
        MiniAppSettingsAccessTokenView.ErrorBehavior(rawValue: store.accessTokenErrorBehavior) ?? .normal
    }

    func saveAccessTokenBehavior(behavior: MiniAppSettingsAccessTokenView.ErrorBehavior) {
        store.accessTokenErrorBehavior = behavior.rawValue
    }

    func getAccessTokenError() -> String {
        store.accessTokenErrorMessage
    }

    func saveAccessTokenErrorString(text: String) {
        store.accessTokenErrorMessage = text
    }

    func retrieveAccessTokenInfo() -> AccessTokenInfo {
        guard let tokenInfo = getTokenInfo() else {
            return setDefaultTokenInfo()
        }
        return tokenInfo
    }

    func setDefaultTokenInfo() -> AccessTokenInfo {
        saveTokenInfo(accessToken: "ACCESS_TOKEN", expiryDate: Date(), scopes: nil)
        return AccessTokenInfo(accessToken: "ACCESS_TOKEN", expiry: Date(), scopes: nil)
    }

    func saveTokenDetails(accessToken: String?, date: Date) -> Bool {
        let saveStatus = saveTokenInfo(
            accessToken: accessToken ?? "ACCESS_TOKEN",
            expiryDate: date,
            scopes: nil
        )
        return saveStatus
    }

    // MARK: - Points
    func getPoints() -> UserPointsModel? {
        getUserPoints()
    }

    func savePoints(model: UserPointsModel) {
        _ = saveUserPoints(pointsModel: model)
    }

    // MARK: - Signature
    func getSignature() -> MiniAppSettingsSignatureView.SignatureMode {
        if let forceCheck = store.signatureVerification {
            return forceCheck ? .mandatory : .optional
        } else {
            return .plist
        }
    }

    func saveSignature(mode: MiniAppSettingsSignatureView.SignatureMode) {
        switch mode {
        case .plist:
            store.signatureVerification = nil
        case .optional:
            store.signatureVerification = false
        case .mandatory:
            store.signatureVerification = true
        }
    }
}

extension MiniAppSettingsViewModel {
    enum State {
        case none
        case loading
        case error(Error)
        case success
    }
}
