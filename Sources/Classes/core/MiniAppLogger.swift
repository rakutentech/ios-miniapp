import os

extension OSLog {
    static let sdk = OSLog(category: "Mini App SDK")

    private convenience init(category: String, bundle: Bundle = Bundle(for: MiniAppLogger.self)) {
        let identifier = bundle.infoDictionary?["CFBundleIdentifier"] as? String
        self.init(subsystem: (identifier ?? "").appending(".logs"), category: category)
    }
}

internal class MiniAppLogger {
    static let encoder = JSONEncoder()
    /// Debug
    class func d(_ message: String, _ customBullet: String? = nil, _ showDate: Bool = false) {
        #if DEBUG
        print("\(customBullet ?? "🔍")\(showDate ? "\(Date().timeIntervalSince1970) " : "") \(message)")
        #endif
    }

    /// Debug
    class func d<T: Codable>(codable: T, _ customBullet: String? = nil, _ showDate: Bool = false, outputFormatting: JSONEncoder.OutputFormatting = .prettyPrinted) {
        #if DEBUG
        encoder.outputFormatting = outputFormatting
        if let jsonData = try? Self.encoder.encode(codable), let jsonString = String(data: jsonData, encoding: . utf8) {
            d(jsonString)
        }
        #endif
    }

    /// Verbose
    class func v(_ message: String) {
        #if DEBUG
        // Disabled by default to prevent spamming apps with verbose logging.
        // In future this could be made switchable via plist.
        // print("🔍 \(message)")
        #endif
    }

    /// Error
    class func e(_ message: String) {
        #if DEBUG
        print("❌ \(message)")
        #else
        os_log("%@", log: OSLog.sdk, type: .error, message)
        #endif
    }

    /// Error
    class func e(_ message: String, _ error: Error) {
        #if DEBUG
        e("\(message)\nError: \(error)")
        #else
        os_log("%@", log: OSLog.sdk, type: .error, message)
        #endif
    }

    /// Warning
    class func w(_ message: String) {
        #if DEBUG
        print("⚠️ \(message)")
        #else
        os_log("%@", log: OSLog.sdk, type: .debug, message)
        #endif
    }
}
