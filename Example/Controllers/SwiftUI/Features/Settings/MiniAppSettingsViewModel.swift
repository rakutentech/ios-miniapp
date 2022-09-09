import Foundation
import MiniApp
import Combine

@MainActor
class MiniAppSettingsViewModel: ObservableObject {

    let store = MiniAppStore.shared

    @Published var indexedMiniAppInfoList: [String: [MiniAppInfo]] = [:]
    @Published var state: State = .none
    @Published var config = MiniAppSettingsView.SettingsConfig()

    var bag = Set<AnyCancellable>()

    init() {
        print(Config.string(.production, key: .subscriptionKeyList2, withFallback: true) ?? "")
        print("-")
//        store.$indexedMiniAppInfoList
//            .sink { [weak self] list in
//                self?.indexedMiniAppInfoList = list
//            }
//            .store(in: &bag)
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

    func save(config: MiniAppSettingsView.SettingsConfig, completion: @escaping (() -> Void)) {
        
        state = .loading
        
        let sdkConfig = MiniAppSdkConfig(
            rasProjectId: config.listIProjectId,
            subscriptionKey: config.listISubscriptionKey,
            isPreviewMode: config.previewMode == .previewable
        )
        
        MiniApp.shared(with: sdkConfig).list { [weak self] (result) in
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(750)) {
                switch result {
                case let .success(infos):
                    self?.persistConfig(config: config)
                    self?.store.update(type: .listI, infos: infos)
                    self?.state = .success
                case .failure(let error):
                    self?.state = .error(error)
                }
                completion()
            }
        }
        
        let sdkConfig2 = MiniAppSdkConfig(
            rasProjectId: config.listIIProjectId,
            subscriptionKey: config.listIISubscriptionKey,
            isPreviewMode: config.previewMode == .previewable
        )
        
        MiniApp.shared(with: sdkConfig2).list { [weak self] (result) in
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(750)) {
                switch result {
                case let .success(infos):
                    self?.store.update(type: .listII, infos: infos)
                case .failure(let error):
                    self?.state = .error(error)
                }
                completion()
            }
        }
    }

    func persistConfig(config: MiniAppSettingsView.SettingsConfig) {
        if !store.miniAppSetupCompleted {
            _ = saveUserPoints(pointsModel: UserPointsModel(standardPoints: 10, termPoints: 20, cashPoints: 30))
            store.miniAppSetupCompleted = true
        }
        //Config.userDefaults?.set(config.previewMode == .previewable, forKey: Config.Key.isPreviewMode.rawValue)
        
        Config.setUserDefaultsBool(key: .isPreviewMode, value: config.previewMode == .previewable)
        Config.changeEnvironment(isStaging: config.environmentMode == .staging)
        
        Config.setString(.production, key: .projectId, value: config.listIProjectId)
        Config.setString(.production, key: .subscriptionKey, value: config.listISubscriptionKey)
        Config.setString(.staging, key: .projectId, value: config.listIStagingProjectId)
        Config.setString(.staging, key: .subscriptionKey, value: config.listIStagingSubscriptionKey)
        
        Config.setString(.production, key: .projectIdList2, value: config.listIIProjectId)
        Config.setString(.production, key: .subscriptionKeyList2, value: config.listIISubscriptionKey)
        Config.setString(.staging, key: .projectIdList2, value: config.listIStagingProjectId)
        Config.setString(.staging, key: .subscriptionKeyList2, value: config.listIIStagingSubscriptionKey)
        
        
//        Config.setUserDefaultsString(key: .projectId, value: config.listIProjectId)
//        Config.setUserDefaultsString(key: .subscriptionKey, value: config.listISubscriptionKey)
//        Config.setUserDefaultsString(key: .projectIdList2, value: config.listIIProjectId)
//        Config.setUserDefaultsString(key: .subscriptionKeyList2, value: config.listIISubscriptionKey)
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

//    var secureStorageLimit: String {
//        get {
//            store.getSecureStorageLimitString()
//        }
//        set {
//            store.setSecureStorageLimit(maxSize: 0)
//        }
//    }

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
        saveUserPoints(pointsModel: model)
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
