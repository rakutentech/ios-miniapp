import Foundation
import UIKit

extension String {

    var hasHTTPPrefix: Bool {
        return lowercased().hasPrefix("http://") || lowercased().hasPrefix("https://")
    }

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

    func convertBase64ToImage() -> UIImage? {
        if let url = URL(string: self), let imageData = try? Data(contentsOf: url), let profileImage = UIImage(data: imageData) {
            return profileImage
        }
        return nil
    }

    func isValueEmpty() -> Bool {
        if self.isEmpty || self.trimTrailingWhitespaces().isEmpty {
            return true
        }
        return false
    }

    func isValidEmail() -> Bool {
        return NSPredicate(format: "SELF MATCHES %@",
                           "(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
                           + "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
                           + "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
                           + "z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
                           + "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
                           + "9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
                           + "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])").evaluate(with: self)
    }
}

extension NSMutableAttributedString {
    func bold(_ value: String, fontSize: CGFloat = 14) -> NSMutableAttributedString {
        let font: UIFont = UIFont.boldSystemFont(ofSize: fontSize)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        append(NSAttributedString(string: value, attributes: attributes))
        return self
    }

    func normal(_ value: String, fontSize: CGFloat = 14) -> NSMutableAttributedString {
        let font: UIFont = UIFont.systemFont(ofSize: fontSize)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        append(NSAttributedString(string: value, attributes: attributes))
        return self
    }
}
