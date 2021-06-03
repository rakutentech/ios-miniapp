import Foundation
import UIKit

extension UITextField {

    func isTextFieldEmpty() -> Bool {
        guard let textfieldValue = self.text, !textfieldValue.isValueEmpty() else {
            return true
        }
        return false
    }
}
