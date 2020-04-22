import Foundation

extension String {

    func isValidUUID() -> Bool {
        if(self.range(of: #"[0-9a-f]{8}-?[0-9a-f]{4}-?[0-9a-f]{4}-?[0-9a-f]{4}-?[0-9a-f]{12}+$"#,
                         options: .regularExpression) != nil) {
             return true
         }
         return false
    }
}
