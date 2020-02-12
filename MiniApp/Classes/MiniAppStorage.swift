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
}
