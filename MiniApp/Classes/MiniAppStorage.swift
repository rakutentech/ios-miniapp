class MiniAppStorage {
    internal func save(sourcePath: URL, destinationPath: URL) {
        try? FileManager.default.createDirectory(atPath: destinationPath.relativePath, withIntermediateDirectories: true)
        try? FileManager.default.removeItem(at: destinationPath)
        try? FileManager.default.copyItem(at: sourcePath, to: destinationPath)
    }
}
