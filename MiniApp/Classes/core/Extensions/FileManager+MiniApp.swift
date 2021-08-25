/**
 * MiniAppSDK helper methods by extending FileManager.
 */
extension FileManager {

    // Store an encodable struct to the specified directory on disk
    ///
    /// - Parameters:
    ///   - object: the encodable struct to store
    ///   - directory: where to store the struct
    ///   - fileName: what to name the file where the struct data will be stored
    @discardableResult func store<EncodableType: Encodable>(_ object: EncodableType, to directory: String, as fileName: String) -> Bool {
        let encoder = JSONEncoder()
        #if DEBUG
        encoder.outputFormatting = .prettyPrinted
        #endif
        do {
            let data = try encoder.encode(object)
            guard let url = URL(string: directory)?.appendingPathComponent(fileName, isDirectory: false) else {
                return false
            }
            if fileExists(atPath: url.path) {
                try? removeItem(at: url)
            }
            if createFile(atPath: url.path, contents: data, attributes: nil) {
                MiniAppLogger.d("\(fileName) stored at path \(directory)", "📂")
                return true
            } else {
                MiniAppLogger.w("\(fileName) not stored at path \(directory)")
            }
        } catch {
            MiniAppLogger.e("Error writing", error)
        }
        return false
    }

    /// Retrieve and convert a struct from a file on disk
    ///
    /// - Parameters:
    ///   - fileName: name of the file where struct data is stored
    ///   - directory: directory where struct data is stored
    ///   - type: struct type (i.e. Message.self)
    /// - Returns: decoded struct model(s) of data
    func retrieve<T: Decodable>(_ fileName: String, from directory: URL, as type: T.Type) -> T? {
        let url = directory.appendingPathComponent(fileName, isDirectory: false)
        guard fileExists(atPath: url.path) else {
            MiniAppLogger.e("\(fileName) at path \(url.path) does not exist!")
            return nil
        }

        if let data = contents(atPath: url.path) {
            let decoder = JSONDecoder()
            do {
                let model = try decoder.decode(type, from: data)
                return model
            } catch {
                MiniAppLogger.e("Error while reading \(fileName)", error)
            }
        } else {
            MiniAppLogger.e("No data at \(url.path)!")
        }

        return nil
    }

    /// Remove specified file from specified directory
    func remove(_ fileName: String, from directory: URL) {
        let url = directory.appendingPathComponent(fileName, isDirectory: false)
        if fileExists(atPath: url.path) {
            do {
                try removeItem(at: url)
            } catch {
                MiniAppLogger.e("Error while deleting \(fileName) at \(url.path)", error)
            }
        }
    }

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
