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

    init(appId: String) {
        self.appId = appId
    }

    func load(completion: ((MiniAppSecureStorageError?) -> Void)?) {
        let databasePath = "/\(appId)/\(MiniAppSecureStorageSqliteDatabase.storageFullName)"
        let databaseUrl = FileManager.getMiniAppFolderPath().appendingPathComponent(databasePath)
        do {
            let dbQueue = try Connection(databaseUrl.path)
            self.dbQueue = dbQueue
            do {
                try Entry.migrate(database: dbQueue)
                MiniAppLogger.d("🔑 Secure Storage: entries table created")
                completion?(nil)
            } catch {
                MiniAppLogger.d("🔑 Secure Storage: entries table exists")
                completion?(nil)
            }
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

    static func wipe() {
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
            }
        }
    }

    static func wipe(for miniAppId: String) {
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
            }
        }
    }
}
