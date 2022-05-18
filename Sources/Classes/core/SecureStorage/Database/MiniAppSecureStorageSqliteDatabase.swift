import Foundation
import GRDB

class MiniAppSecureStorageSqliteDatabase: MiniAppSecureStorageDatabase {

    var appId: String

    static let storageName: String = MiniAppSecureStorage.storageName
    static let storageNameExtension: String = "sqlite"
    static var storageFullName: String { return storageName + ".\(storageNameExtension)" }

    private(set) var dbQueue: DatabaseQueue?

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
            let dbQueue = try DatabaseQueue(path: databaseUrl.path)
            do {
                try dbQueue.write { database in
                    try database.create(table: "entries") { table in
                        table.column("key", .text).primaryKey().notNull()
                        table.column("value", .text).notNull()
                    }
                }
                print("table created")
            } catch {
                print("table already exists")
            }
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
        let ent = try dbQueue.read { database -> Entry? in
            return try Entry.fetchOne(database, key: key)
        }
        return ent
    }

    func save(completion: ((Result<Bool, MiniAppSecureStorageError>) -> Void)? = nil) throws {
        completion?(.success(true))
    }

    func get(key: String) throws -> String? {
        return try find(for: key)?.value
    }

    func set(dict: [String: String]) throws {
        guard let dbQueue = dbQueue else { throw MiniAppSecureStorageError.storageUnvailable }
        try dbQueue.write { database in
            for (key, value) in dict {
                let entry = Entry(key: key, value: value)
                try entry.save(database)
            }
        }
    }

    func remove(keys: [String]) throws {
        guard let dbQueue = dbQueue else { throw MiniAppSecureStorageError.storageUnvailable }
        for key in keys {
            _ = try dbQueue.write { database in
                if try Entry.exists(database, key: key) {
                    try Entry.deleteOne(database, key: key)
                } else {
                    throw MiniAppSecureStorageError.storageIOError
                }
            }
        }
    }

    func clear(completion: ((Result<Bool, MiniAppSecureStorageError>) -> Void)? = nil) {
        MiniAppLogger.d("🔑 Secure Storage: clear")
        guard let dbQueue = dbQueue else {
            completion?(.failure(MiniAppSecureStorageError.storageUnvailable))
            return
        }
        do {
            _ = try dbQueue.write { database in
                try Entry.deleteAll(database)
                completion?(.success(true))
            }
        } catch {
            completion?(.failure(MiniAppSecureStorageError.storageIOError))
            return
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
