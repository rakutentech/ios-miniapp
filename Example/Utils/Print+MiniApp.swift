import Foundation

func log(_ message: String, prefix: String? = "📱") {
    print("\(prefix == nil ? "" : prefix! + " ")\(message)")
}
