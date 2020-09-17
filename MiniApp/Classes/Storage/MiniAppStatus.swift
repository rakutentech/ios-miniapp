class MiniAppStatus {
    private let defaults: UserDefaults?
    private let miniAppInfoDefaults: UserDefaults?
    private let miniAppKeyStore: MiniAppKeyChain

    init() {
        self.defaults = UserDefaults(suiteName: "com.rakuten.tech.mobile.miniapp")
        self.miniAppInfoDefaults = UserDefaults(suiteName: "com.rakuten.tech.mobile.miniapp.MiniAppDemo.MiniAppInfo")
        self.miniAppKeyStore = MiniAppKeyChain()
    }

    func setDownloadStatus(_ value: Bool, appId: String, versionId: String) {
        setDownloadStatus(value, for: "\(appId)/\(versionId)")
    }

    func setDownloadStatus(_ value: Bool, for key: String) {
        defaults?.setValue(value, forKey: key)
    }

    func isDownloaded(appId: String, versionId: String) -> Bool {
        isDownloaded(key: "\(appId)/\(versionId)")
    }

    func isDownloaded(key: String) -> Bool {
        return defaults?.bool(forKey: key) ?? false
    }

    func setCachedVersion(_ version: String, for key: String) {
        defaults?.setValue(version, forKey: key)
    }

    func getCachedVersion(key: String) -> String {
        return defaults?.string(forKey: key) ?? ""
    }

    func saveMiniAppInfo(appInfo: MiniAppInfo, key: String) {
        if let data = try? PropertyListEncoder().encode(appInfo) {
            self.miniAppInfoDefaults?.set(data, forKey: key)
        }
    }

    func getMiniAppInfo(appId: String) -> MiniAppInfo? {
        if let data = self.miniAppInfoDefaults?.data(forKey: appId) {
            let miniAppInfo = try? PropertyListDecoder().decode(MiniAppInfo.self, from: data)
            return miniAppInfo
        }
        return nil
    }
    
    func getDownloadedListWithCustomPermissionsInfo() {
        var permissionsList = self.miniAppKeyStore.getAllStoredCustomPermissionsList()
        let downloadedList = getDownloadedMiniAppsList()
        let mod = permissionsList?.keys.map { miniAppId in
            print(miniAppId)
            if downloadedList?.contains(where: { $0.id == miniAppId }) ?? false {
                print("")
                var index = downloadedList?.firstIndex { $0.id == miniAppId }
                return
            } else {
                // Delete the value from Keychain
                // return nil
            }
            print("")
        }
    }
    
    func getDownloadedMiniAppsList() -> [MiniAppInfo]? {
        let dictList = self.miniAppInfoDefaults?.dictionaryRepresentation().map { dict -> MiniAppInfo? in
            if let data = dict.value as? Data {
                if let miniAppInfo = try? PropertyListDecoder().decode(MiniAppInfo.self, from: data) {
                    return miniAppInfo
                }
            }
            return nil
        }
        return dictList?.compactMap{$0}
    }
}
