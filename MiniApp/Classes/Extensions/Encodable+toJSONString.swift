import Foundation

extension Encodable {
	func toJSONString() -> String? {
		guard let jsonData = try? JSONEncoder().encode(self) else {
			return nil
		}
		return String(data: jsonData, encoding: .utf8)
	}
}
