import Foundation
import UIKit

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

    func convertBase64ToImage() -> UIImage? {
        if let url = URL(string: self), let imageData = try? Data(contentsOf: url), let profileImage = UIImage(data: imageData) {
            return profileImage
        }
        return nil
    }
}
