import Foundation
import MiniApp
import Combine

@MainActor
class MiniAppSettingsViewModel: ObservableObject {

    let store = MiniAppStore.shared

    @Published var indexedMiniAppInfoList: [String: [MiniAppInfo]] = [:]
    @Published var state: State = .none
    var config: MiniAppSettingsView.SettingsConfig {
        get {
            store.config
        }
        set {
            store.config = newValue
        }
    }

    var bag = Set<AnyCancellable>()

    init() {
        //
    }

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

        let configListI = config.sdkConfig(list: .listI)
        MiniApp
            .shared(with: configListI)
            .list { [weak self] (result) in
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(750)) {
                    switch result {
                    case let .success(infos):
                        self?.persistConfig()
                        self?.store.update(type: .listI, infos: infos)
                        self?.state = .success
                    case .failure(let error):
                        self?.state = .error(error)
                    }
                    completion?()
                }
            }

        let configListII: MiniAppSdkConfig = config.sdkConfig(list: .listII)
        MiniApp
            .shared(with: configListII)
            .list { [weak self] (result) in
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(750)) {
                    switch result {
                    case let .success(infos):
                        self?.persistConfig()
                        self?.store.update(type: .listII, infos: infos)
                    case .failure(let error):
                        self?.state = .error(error)
                    }
                    completion?()
                }
            }
    }

    func persistConfig() {
        if !store.miniAppSetupCompleted {
            store.miniAppSetupCompleted = true
        }

        NewConfig.setValue(.isPreviewMode, value: config.previewMode == .previewable)
        NewConfig.setValue(.environment, value: config.environmentMode == .production)

        // list 1
        NewConfig.setString(.production, key: .projectId, value: config.listIProjectId)
        NewConfig.setString(.production, key: .subscriptionKey, value: config.listISubscriptionKey)
        NewConfig.setString(.staging, key: .projectId, value: config.listIStagingProjectId)
        NewConfig.setString(.staging, key: .subscriptionKey, value: config.listIStagingSubscriptionKey)

        // list 2
        NewConfig.setString(.production, key: .projectIdList2, value: config.listIIProjectId)
        NewConfig.setString(.production, key: .subscriptionKeyList2, value: config.listIISubscriptionKey)
        NewConfig.setString(.staging, key: .projectIdList2, value: config.listIIStagingProjectId)
        NewConfig.setString(.staging, key: .subscriptionKeyList2, value: config.listIIStagingSubscriptionKey)
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
