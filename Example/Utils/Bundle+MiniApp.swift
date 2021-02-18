import Foundation
import UIKit

extension Bundle {
    var valueNotFound: String {
        return ""
    }

    func value(for key: String) -> String? {
        return self.object(forInfoDictionaryKey: key) as? String
    }
}
