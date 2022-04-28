import Foundation

class Base64UriHelper {
    /// regex splits the string into 4 groups (whole match, 1st group "image" / "application", 2nd group "jpg", "zip" etc, meta data
    static let base64CapturePattern = #"^data:([a-z0-9\.\-\+]+)\/([a-z0-9\,\.\-\+]+);([\s]?[\S]*;)?base64,"#

    static func isBase64String(text: String) -> Bool {
        let capturePattern = base64CapturePattern
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

    static func decodeBase64String(text: String) -> Data? {
        let capturePattern = base64CapturePattern
        guard
            let captureRegex = try? NSRegularExpression(
                pattern: capturePattern,
                options: []
            )
        else { return nil }

        let textRange = NSRange(
            text.startIndex..<text.endIndex,
            in: text
        )

        if let match = captureRegex.firstMatch(in: text, options: [], range: textRange) {
            guard match.numberOfRanges >= 3 else { return nil }

            let base64String = removeBase64Header(text: text, range: match.range(at: 0))
            guard
                let baseData = base64String.data(using: .utf8),
                let baseEncodedData = Data(base64Encoded: baseData, options: .ignoreUnknownCharacters)
            else { return nil }

            return baseEncodedData
        } else { return nil }
    }

    static func removeBase64Header(text: String, range: NSRange? = nil) -> String {
        if let objcRange = range, let swiftRange = Range(objcRange, in: text) {
            var base64Text = text
            base64Text.removeSubrange(swiftRange)
            return base64Text
        } else { // fallback method if something is wrong with the range
            return text.replacingOccurrences(of: base64CapturePattern, with: "", options: .regularExpression)
        }
    }
}
