import Foundation

extension String {

    func isValidUUID() -> Bool {
        if UUID(uuidString: self) != nil {
            return true
        }
        return false
    }
}
