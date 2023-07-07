import Foundation
import MiniApp

class MAAnalyticsInfoLogger {
    static var logFile: URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let fileName = "MAAnalyticsInfoLogs.txt"
        return documentsDirectory.appendingPathComponent(fileName)
    }

    static func startLogs(forMiniApp miniAppId: String) {
        MAAnalyticsInfoLogger.logAnalytics("--------------------------------- \nMiniApp -> \(miniAppId) is OPENED")
    }

    func stopLogs(forMiniApp miniAppId: String) {
        MAAnalyticsInfoLogger.logAnalytics("MiniApp -> \(miniAppId) is CLOSED \n ---------------------------------")
    }

    static func logAnalyticsInfo(_ analyticsInfo: MAAnalyticsInfo) {
        let jsonEncoder = JSONEncoder()
        guard let jsonData = try? jsonEncoder.encode(analyticsInfo) else { return }
        let jsonString = String(data: jsonData,
                                encoding: .utf8)
        MAAnalyticsInfoLogger.logAnalytics("AnalyticsInfo : \(jsonString ?? "")")
    }

    static func logAnalytics(_ message: String) {
        guard let logFile = logFile else {
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/YYY :: HH:mm:ss"
        let timestamp = formatter.string(from: Date())
        guard let data = (timestamp + ": " + message + "\n").data(using: String.Encoding.utf8) else { return }

        if FileManager.default.fileExists(atPath: logFile.path) {
            if let fileHandle = try? FileHandle(forWritingTo: logFile) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            }
        } else {
            try? data.write(to: logFile, options: .atomicWrite)
        }
    }

    static func readAnalyticsInfoLogs() -> String {
        guard let logFile = logFile else {
            return NSLocalizedString("demo.app.analytics.info.sorryNoData", comment: "")
        }
        do {
            let data = try Data(contentsOf: logFile)
            if let string = String(data: data, encoding: .utf8) {
                return string
            }
        } catch {
            print("Error reading file: \(error)")
            return NSLocalizedString("demo.app.analytics.info.dataNotExists", comment: "")
        }
        return NSLocalizedString("demo.app.analytics.info.dataNotExists", comment: "")
    }

    static func deleteAnalyticsInfoLogs() {
        guard let logFile = logFile else {
            return
        }
        do {
            try FileManager.default.removeItem(at: logFile)
            print("Successfully deleted file!")
        } catch {
            print("Error deleting file: \(error)")
        }
    }
}
