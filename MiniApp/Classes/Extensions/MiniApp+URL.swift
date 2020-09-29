extension URL {
    func fileExtension() -> String {
        (self.absoluteString as NSString).pathExtension.lowercased()
    }

    func isMiniAppURL() -> Bool {
        return scheme?.starts(with: Constants.miniAppSchemePrefix) ?? false
    }
}
