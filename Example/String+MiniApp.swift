import Foundation

extension String {

    func isValidUUID() -> Bool {
        if UUID(uuidString: self) != nil {
            return true
        }
        return false
    }

    func trimTrailingWhitespaces() -> String {
        if let trailingEmptyString = self.range(of: "\\s+$", options: .regularExpression) {
            return self.replacingCharacters(in: trailingEmptyString, with: "")
        } else {
            return self
        }
    }
}
