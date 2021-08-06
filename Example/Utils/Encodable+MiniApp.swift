import Foundation

extension Encodable {
    var JSONString: String {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted),
              let output = String(data: jsonData, encoding: .utf8) else {
            if let dict = self as? [String: String] {
                var output: String = ""
                for (key, value) in dict {
                    output += "\"\(key)\" : \"\(value)\","
                }
                return "{"+String(output.dropLast())+"}"
            }
            return "{\(self)}"
        }
        return output
    }
}
