extension URL {
    func fileExtension() -> String {
        (self.absoluteString as NSString).pathExtension.lowercased()
    }

    func isMiniAppURL(customMiniAppURL: URL? = nil) -> Bool {
        if let miniAppURL = customMiniAppURL {
            return host?.lowercased() == miniAppURL.host?.lowercased()
        }
        return scheme?.starts(with: Constants.miniAppSchemePrefix) ?? false
    }
}
