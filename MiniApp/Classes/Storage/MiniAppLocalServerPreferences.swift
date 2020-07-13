class MiniAppLocalServerPreferences {
    private let defaults: UserDefaults?

    init() {
        self.defaults = UserDefaults(suiteName: "com.rakuten.tech.mobile.miniapp.server")
    }

    func savePortNumberForMiniApp(appId: String, portNumber: Int) {
        defaults?.setValue(portNumber, forKey: appId)
    }

    func getPortNumberForMiniApp(key: String) -> Int {
        return defaults?.integer(forKey: key) ?? 0
    }
}
