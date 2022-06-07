import Foundation

public protocol MiniAppSecureStorageDatabase: AnyObject {
    var appId: String {get set}
    var isStoreAvailable: Bool {get}
    var storageFullName: String {get}

    static var storageFullName: String {get}

    func setup() throws
    func load(completion: ((MiniAppSecureStorageError?) -> Void)?)
    func unload() throws
    func get(key: String) throws -> String?
    func set(dict: [String: String]) throws
    func remove(keys: [String]) throws
    func save(completion: ((Result<Bool, MiniAppSecureStorageError>) -> Void)?) throws
    func clear(completion: ((Result<Bool, MiniAppSecureStorageError>) -> Void)?)

    static func wipe() throws
    static func wipe(for miniAppId: String) throws
}

extension MiniAppSecureStorageDatabase {
    static func wipe() throws {
        guard let contentNames = try? FileManager
                .default
                .contentsOfDirectory(atPath: FileManager.getMiniAppFolderPath().path)
        else { return }
        for name in contentNames {
            let url = FileManager.getMiniAppFolderPath().appendingPathComponent("/" + name)
            do {
                if let isDirectory = (try url.resourceValues(forKeys: [.isDirectoryKey])).isDirectory, isDirectory {
                    do {
                        try FileManager
                            .default
                            .removeItem(at: url.appendingPathComponent("/" + storageFullName))
                        MiniAppLogger.d("🔑 Secure Storage: destroyed storaged for \(name)")
                    } catch {
                        MiniAppLogger.d("🔑 Secure Storage: could not destroy storage for \(name)")
                    }
                } else {
                    MiniAppLogger.d("🔑 Secure Storage: ignored \(name)")
                }
            } catch let error {
                MiniAppLogger.d("🔑 Secure Storage Wipe Failed: \(name)", error.localizedDescription)
                throw MiniAppSecureStorageError.storageIOError
            }
        }
    }

    static func wipe(for miniAppId: String) throws {
        if !miniAppId.isEmpty {
            MiniAppLogger.d("🔑 Secure Storage for MiniApp ID: destroy")
            let miniAppPath = FileManager.getMiniAppFolderPath().appendingPathComponent(miniAppId)
            do {
                try FileManager
                    .default
                    .removeItem(at: miniAppPath.appendingPathComponent("/" + storageFullName))
                MiniAppLogger.d("🔑 Secure Storage for MiniApp ID: destroyed storage for \(miniAppId)")
            } catch {
                MiniAppLogger.d("🔑 Secure Storage for MiniApp ID: could not destroy storaged for \(miniAppId)")
                throw MiniAppSecureStorageError.storageIOError
            }
        }
    }
}

extension MiniAppSecureStorageDatabase {
    func storagePath(appId: String) -> URL {
        return FileManager.getMiniAppDirectory(with: appId).appendingPathComponent("/\(storageFullName)")
    }

    var storageFileSize: UInt64 {
        let fileSize = storagePath(appId: appId).fileSize
        MiniAppLogger.d("🔑 Secure Storage: File size -> \(fileSize)")
        return fileSize
    }

    func storageSize(for miniAppId: String) -> UInt64 {
        let fileSize = storagePath(appId: miniAppId).fileSize
        MiniAppLogger.d("🔑 Secure Storage: File size -> \(fileSize)")
        return fileSize
    }
}

extension MiniAppSecureStorageDatabase {
    static func miniAppPath(appId: String) -> URL {
        return FileManager.getMiniAppDirectory(with: appId)
    }

    static func storagePath(appId: String) -> URL {
        return FileManager.getMiniAppDirectory(with: appId).appendingPathComponent("/\(storageFullName)")
    }
}
