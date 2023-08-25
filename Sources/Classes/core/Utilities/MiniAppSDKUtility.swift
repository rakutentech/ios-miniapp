import Foundation
import CommonCrypto

class MiniAppSDKUtility {
    internal static func unzipMiniApp(fileName: String, miniAppId: String, versionId: String) {
        let cacheVerifier = MiniAppCacheVerifier()
        guard let filePath = Bundle.main.url(forResource: fileName, withExtension: "zip") else {
            return
        }
        do {
            try FileManager.default.unzipItem(at: filePath, to: FileManager.getMiniAppVersionDirectory(with: miniAppId, and: versionId), skipCRC32: true)
            cacheVerifier.storeHash(for: miniAppId, version: versionId)
        } catch let err {
            MiniAppLogger.e("error unzipping archive", err)
        }
    }

    internal static func cleanMiniAppVersions(appId: String, exceptForVersionId: String) {
        guard !appId.isEmpty, !exceptForVersionId.isEmpty else {
            return
        }
        MiniAppStorage.cleanVersions(for: appId, differentFrom: exceptForVersionId)
    }

    internal static func isMiniAppAvailable(appId: String, versionId: String) -> Bool {
        guard !appId.isEmpty, !versionId.isEmpty else {
            return false
        }
        let versionDirectory = FileManager.getMiniAppVersionDirectory(with: appId, and: versionId)
        let miniAppRootPath = "\(versionDirectory.path)/\(Constants.rootFileName)"
        if FileManager.default.fileExists(atPath: miniAppRootPath) {
            return true
        }
        return false
    }
}
