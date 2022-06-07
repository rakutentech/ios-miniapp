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
            completion?(.storageUnavailable)
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
        guard let dbQueue = dbQueue else { throw MiniAppSecureStorageError.storageUnavailable }
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
        guard let dbQueue = dbQueue else { throw MiniAppSecureStorageError.storageUnavailable }
        for (key, value) in dict {
            let upsertResult = try Entry.upsert(database: dbQueue, key: key, value: value)
            MiniAppLogger.d("🔑 Secure Storage: upsert -> \(upsertResult)")
        }
    }

    func remove(keys: [String]) throws {
        guard let dbQueue = dbQueue else { throw MiniAppSecureStorageError.storageUnavailable }
        for key in keys {
            let deleteResult = try Entry.delete(database: dbQueue, key: key)
            MiniAppLogger.d("🔑 Secure Storage: delete -> \(deleteResult)")
        }
    }

    func clear(completion: ((Swift.Result<Bool, MiniAppSecureStorageError>) -> Void)? = nil) {
        MiniAppLogger.d("🔑 Secure Storage: clear")
        guard let dbQueue = dbQueue else {
            completion?(.failure(MiniAppSecureStorageError.storageUnavailable))
            return
        }
        do {
            try Entry.deleteAll(database: dbQueue)
            completion?(.success(true))
        } catch {
            completion?(.failure(.storageIOError))
        }
    }
}
