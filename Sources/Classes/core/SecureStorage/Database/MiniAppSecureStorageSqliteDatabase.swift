import Foundation
import SQLite

class MiniAppSecureStorageSqliteDatabase: MiniAppSecureStorageDatabase {

    var appId: String

    static let storageName: String = MiniAppSecureStorage.storageName
    static let storageNameExtension: String = "sqlite"
    static var storageFullName: String { return storageName + ".\(storageNameExtension)" }

    private(set) var dbQueue: Connection?

    var isStoreAvailable: Bool {
        return dbQueue != nil
    }

    var storageFullName: String { return Self.storageFullName }

    var storagePath: String {
        let databasePath = "/\(appId)/\(MiniAppSecureStorageSqliteDatabase.storageFullName)"
        let databaseUrl = FileManager.getMiniAppFolderPath().appendingPathComponent(databasePath)
        let databaseUrlPath = databaseUrl.path
        return databaseUrlPath
    }
    var storageExists: Bool {
        return FileManager.default.fileExists(atPath: storagePath)
    }

    init(appId: String) {
        self.appId = appId
    }

    func setup() throws {
        do {
            let dbQueue = try Connection(storagePath)
            self.dbQueue = dbQueue
            do {
                try Entry.migrate(database: dbQueue)
                MiniAppLogger.d("🔑 Secure Storage: entries table created")
            } catch {
                MiniAppLogger.d("🔑 Secure Storage: entries table exists")
            }
        } catch {
            MiniAppLogger.d("🔑 Secure Storage: connection failed")
            throw error
        }
    }

    func load(completion: ((MiniAppSecureStorageError?) -> Void)?) {
        guard storageExists else {
            completion?(.storageUnvailable)
            return
        }
        do {
            let dbQueue = try Connection(storagePath)
            self.dbQueue = dbQueue
            completion?(nil)
        } catch {
            print(error)
            completion?(.storageIOError)
        }
    }

    func unload() throws {
        dbQueue = nil
    }

    func find(for key: String) throws -> Entry? {
        guard let dbQueue = dbQueue else { throw MiniAppSecureStorageError.storageUnvailable }
        return try Entry.find(database: dbQueue, key: key)
    }

    func save(completion: ((Swift.Result<Bool, MiniAppSecureStorageError>) -> Void)? = nil) throws {
        completion?(.success(true))
    }

    func get(key: String) throws -> String? {
        return try find(for: key)?.value
    }

    func set(dict: [String: String]) throws {
        if !storageExists {
            try setup()
        }
        guard let dbQueue = dbQueue else { throw MiniAppSecureStorageError.storageUnvailable }
        for (key, value) in dict {
            try Entry.upsert(database: dbQueue, key: key, value: value)
        }
    }

    func remove(keys: [String]) throws {
        guard let dbQueue = dbQueue else { throw MiniAppSecureStorageError.storageUnvailable }
        for key in keys {
            try Entry.delete(database: dbQueue, key: key)
        }
    }

    func clear(completion: ((Swift.Result<Bool, MiniAppSecureStorageError>) -> Void)? = nil) {
        MiniAppLogger.d("🔑 Secure Storage: clear")
        guard let dbQueue = dbQueue else {
            completion?(.failure(MiniAppSecureStorageError.storageUnvailable))
            return
        }
        do {
            try Entry.deleteAll(database: dbQueue)
            completion?(.success(true))
        } catch {
            completion?(.failure(.storageIOError))
        }
    }

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
                        try FileManager
                            .default
                            .removeItem(at: url.appendingPathComponent("/" + storageFullName.appending("-shm")))
                        try FileManager
                            .default
                            .removeItem(at: url.appendingPathComponent("/" + storageFullName.appending("-wal")))
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
                try FileManager
                    .default
                    .removeItem(at: miniAppPath.appendingPathComponent("/" + storageFullName.appending("-shm")))
                try FileManager
                    .default
                    .removeItem(at: miniAppPath.appendingPathComponent("/" + storageFullName.appending("-wal")))
                MiniAppLogger.d("🔑 Secure Storage for MiniApp ID: destroyed storage for \(miniAppId)")
            } catch {
                MiniAppLogger.d("🔑 Secure Storage for MiniApp ID: could not destroy storaged for \(miniAppId)")
                throw MiniAppSecureStorageError.storageIOError
            }
        }
    }
}
