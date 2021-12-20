class MiniAppStorage {

    internal func save(sourcePath: URL, destinationPath: URL) -> NSError? {
        do {
            try FileManager.default.createDirectory(atPath: destinationPath.relativePath, withIntermediateDirectories: true)
            try FileManager.default.removeItem(at: destinationPath)
            try FileManager.default.copyItem(at: sourcePath, to: destinationPath)
            try FileManager.default.removeItem(at: sourcePath)
            return nil
        } catch let error as NSError {
            return error
        }
    }

    internal func cleanVersions(for appId: String, differentFrom versionId: String, status: MiniAppStatus) {
        let miniAppStoragePath = FileManager.getMiniAppDirectory(with: appId)
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: miniAppStoragePath, includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants)
            for path in directoryContents where (path.lastPathComponent != versionId && path.lastPathComponent != MAManifestStorage.fileName) {
                try FileManager.default.removeItem(at: path)
                status.setDownloadStatus(false, appId: appId, versionId: path.lastPathComponent)
            }
        } catch {
             MiniAppLogger.w("MiniAppDownloader could not delete previously downloaded versions for appId \(appId) (\(error))")
        }
    }
}
