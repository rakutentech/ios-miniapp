class MiniAppStatus {
    private let defaults: UserDefaults?

    init() {
        self.defaults = UserDefaults(suiteName: "com.rakuten.tech.mobile.miniapp")
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
}
