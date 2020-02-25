class MiniAppPreferences {
    private let defaults: UserDefaults?

    init() {
        self.defaults = UserDefaults(suiteName: "com.rakuten.tech.mobile.miniapp")
    }

    func setDownloadStatus(value: Bool, key: String) {
        defaults?.setValue(value, forKey: key)
    }

    func isDownloaded(key: String) -> Bool {
        return defaults?.bool(forKey: key) ?? false
    }
}
