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
    class func getMiniAppDirectory(with appId: String, and versionId: String) -> URL {
        let cachePath =
            FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]

        let miniAppDirectory = "MiniApp/\(appId)/\(versionId)/"

        return cachePath.appendingPathComponent(miniAppDirectory)
    }
}
