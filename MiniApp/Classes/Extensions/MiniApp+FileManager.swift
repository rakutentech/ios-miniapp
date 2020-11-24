/**
 * MiniAppSDK helper methods by extending FileManager.
 */
extension FileManager {

    /*
     * Provide the MiniApp directory by appending the system
     * cache directory with AppID and VersionID.
     * @param { appId: String } - AppID of the MiniApp.
     * @param { versionId: String } - VersionID of the MiniApp.
     * @return { URL } - URL path to the MiniApp.
     */
    class func getMiniAppVersionDirectory(with appId: String, and versionId: String) -> URL {
        return getMiniAppDirectory(with: appId).appendingPathComponent("\(versionId)/")
    }

    /*
     * Provide the MiniApp directory by appending the system
     * cache directory with AppID.
     * @param { appId: String } - AppID of the MiniApp.
     * @return { URL } - URL path to the MiniApp.
     */
    class func getMiniAppDirectory(with appId: String) -> URL {
        let cachePath =
            FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]

        let miniAppDirectory = "MiniApp/\(appId)/"

        return cachePath.appendingPathComponent(miniAppDirectory)
    }

    /// Returns the Mini App version directory for the given app Id
    /// - Parameter appId: { appId: String } - AppID of the MiniApp.
    /// - Parameter version: { version: String? } - version of the MiniApp
    /// - Returns: URL path to the MiniApp.
    class func getMiniAppVersionDirectory(usingAppId id: String, version: String? = nil) -> URL? {
        do {
            let miniAppDir = getMiniAppDirectory(with: id)
            guard let versionId = version else {
                var isDir: ObjCBool = true
                if FileManager.default.fileExists(
                    atPath: miniAppDir.path,
                    isDirectory: &isDir) {
                    let versionDirectory = try FileManager.default.contentsOfDirectory(at: miniAppDir, includingPropertiesForKeys: [URLResourceKey.isDirectoryKey], options: [.skipsHiddenFiles])[0]
                    return versionDirectory
                }
                return nil
            }
            return miniAppDir.appendingPathComponent(versionId)
        } catch let error as NSError {
            print(error.localizedDescription)
            return nil
        }
    }
}
