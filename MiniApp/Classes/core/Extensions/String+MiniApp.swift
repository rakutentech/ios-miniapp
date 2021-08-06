extension String {
    var djb2hash: Int {
        let unicodeScalars = self.unicodeScalars.map { $0.value }
        return unicodeScalars.reduce(5381) {
            ($0 << 5) &+ $0 &+ Int($1)
        }
    }

    var hasHTTPPrefix: Bool {
        lowercased().hasPrefix("http://") || lowercased().hasPrefix("https://")
    }

    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }

    /// Function returns the Localized string for a given Key
    /// If the same key is added in the Host application, then the localizable string from the Host app is returned
    /// - Returns:Localized String from the Bundle
    func localizedString(path: String = Bundle(for: MiniApp.self).path(forResource: "Localization", ofType: "bundle")!) -> String {
        guard let podBundle = Bundle(path: path) else {
            return self
        }
        let defaultValue = NSLocalizedString(self, bundle: podBundle, comment: "")
        return NSLocalizedString(self,
            tableName: "Localizable",
            bundle: Bundle.main,
            value: defaultValue,
            comment: "")
    }
}
