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

    /// Replaces groups of non-alphanumeric characters in URL with '.'
    /// ex. https://endpoint.com/v2/keys/ -> https.endpoint.com.v2.keys
    var identifier: String {
        absoluteString
                .components(separatedBy: CharacterSet.alphanumerics.inverted)
                .filter({ !$0.isEmpty })
                .joined(separator: ".")
                .trimmingCharacters(in: CharacterSet(charactersIn: "."))
    }
}
