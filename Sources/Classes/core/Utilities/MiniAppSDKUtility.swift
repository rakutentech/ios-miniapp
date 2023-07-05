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
}
