import Foundation

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

    var isBase64: Bool {
        let text = self.absoluteString
        let capturePattern = #"^data:([a-z]+)\/([a-z]+);([\S]*;)?base64,"#
        guard
            let captureRegex = try? NSRegularExpression(
                pattern: capturePattern,
                options: []
            )
        else { return false }
        let textRange = NSRange(
            text.startIndex..<text.endIndex,
            in: text
        )
        return captureRegex.firstMatch(in: text, options: [], range: textRange) != nil
    }

    var attributes: [FileAttributeKey: Any]? {
        do {
            return try FileManager.default.attributesOfItem(atPath: path)
        } catch let error as NSError {
            print("FileAttribute error: \(error)")
        }
        return nil
    }

    var fileSize: UInt64 {
        return attributes?[.size] as? UInt64 ?? UInt64(0)
    }

    var fileSizeString: String {
        return ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
    }

    var creationDate: Date? {
        return attributes?[.creationDate] as? Date
    }
}
