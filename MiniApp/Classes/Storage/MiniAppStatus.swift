class MiniAppStatus {
    private let defaults: UserDefaults?
    private let miniAppInfoDefaults: UserDefaults?

    init() {
        self.defaults = UserDefaults(suiteName: "com.rakuten.tech.mobile.miniapp")
        self.miniAppInfoDefaults = UserDefaults(suiteName: "com.rakuten.tech.mobile.miniapp.MiniAppDemo.MiniAppInfo")
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
}
