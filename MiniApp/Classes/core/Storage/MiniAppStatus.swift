class MiniAppStatus {
    private let defaults: UserDefaults?
    private let miniAppInfoDefaults: UserDefaults?
    private let miniAppKeyStore: MiniAppPermissionsStorage

    init() {
        self.defaults = UserDefaults(suiteName: "com.rakuten.tech.mobile.miniapp")
        self.miniAppInfoDefaults = UserDefaults(suiteName: "com.rakuten.tech.mobile.miniapp.MiniAppDemo.MiniAppInfo")
        self.miniAppKeyStore = MiniAppPermissionsStorage()
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

    func getMiniAppsListWithCustomPermissionsInfo() -> MASDKDownloadedListPermissionsPair? {
        guard let downloadedList = getDownloadedMiniAppsList(), downloadedList.count != 0 else {
            return nil
        }
        return getStoredPermissionList(downloadedMiniAppsList: downloadedList.sorted(by: { $0.displayName ?? "" < $1.displayName ?? ""}))
    }

    /// Method to return list of Downloaded Mini apps info. dictionaryRepresentation() returns list of unknown keys from the plist hence we are decoding with MiniAppInfo and returning the same
    /// - Returns: List of downloaded MiniAppInfo
    func getDownloadedMiniAppsList() -> [MiniAppInfo]? {
        let dictList = self.miniAppInfoDefaults?.dictionaryRepresentation().map { dict -> MiniAppInfo? in
            if let data = dict.value as? Data {
                if let miniAppInfo = try? PropertyListDecoder().decode(MiniAppInfo.self, from: data) {
                    return miniAppInfo
                }
            }
            return nil
        }
        return dictList?.compactMap {$0}
    }

    /// Method to return list of MASDKDownloadedListPermissionsPair that contains list of downloaded mini apps info and Custom permissions info
    /// - Parameter downloadedMiniAppsList: List of mini app info that is downloaded
    /// - Returns: List of MASDKDownloadedListPermissionsPair
    func getStoredPermissionList(downloadedMiniAppsList: [MiniAppInfo]) -> MASDKDownloadedListPermissionsPair {
        let finalList = checkStoredPermissionList(downloadedMiniAppsList: downloadedMiniAppsList)
        var returnList: MASDKDownloadedListPermissionsPair = []
        _ = downloadedMiniAppsList.map { (miniAppInfo: MiniAppInfo) in
            if let permMod = finalList[miniAppInfo.id] {
                returnList.append((miniAppInfo, permMod))
            } else {
                returnList.append((miniAppInfo, []))
            }
        }
        return returnList
    }

    /// Method to compare the downloaded mini apps list and stored permissions list. If any discrepancy found then we remove the value from the keychain
    /// - Parameter downloadedMiniAppsList: List of mini app info that is downloaded
    /// - Returns:List of Mini app ID and respective stored custom permissions info
    func checkStoredPermissionList(downloadedMiniAppsList: [MiniAppInfo]?) -> [String: [MASDKCustomPermissionModel]] {
        var storedPermissionsList = self.miniAppKeyStore.getAllStoredCustomPermissionsList()
        guard let downloadedList = downloadedMiniAppsList, downloadedList.count > 0 else {
            _ = storedPermissionsList?.map { (miniAppId: String, _: [MASDKCustomPermissionModel]) in
                self.miniAppKeyStore.removeKey(for: miniAppId)
            }
            return [:]
        }
        _ = storedPermissionsList?.map { (miniAppId: String, _: [MASDKCustomPermissionModel]) in
            if !downloadedList.contains(where: { $0.id == miniAppId }) {
                storedPermissionsList?.removeValue(forKey: miniAppId)
                self.miniAppKeyStore.removeKey(for: miniAppId)
            }
        }
        return storedPermissionsList ?? [:]
    }

    /// Method to delete the existing custom permissions from the Keychain. Keystore should keep Custom Permissions for only downloaded mini-apps
    func removeUnusedCustomPermissions() {
        guard let downloadedList = getDownloadedMiniAppsList(), downloadedList.count != 0 else {
            return
        }
        _ = checkStoredPermissionList(downloadedMiniAppsList: downloadedList)
    }
}
