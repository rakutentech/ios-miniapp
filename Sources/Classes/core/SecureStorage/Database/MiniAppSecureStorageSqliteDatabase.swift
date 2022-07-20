import Foundation
import SQLite
import SQLite3

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

    var storageUrl: URL {
        let databasePath = "/\(appId)/\(MiniAppSecureStorageSqliteDatabase.storageFullName)"
        let databaseUrl = FileManager.getMiniAppFolderPath().appendingPathComponent(databasePath)
        return databaseUrl
    }

    var storagePath: String {
        let databaseUrlPath = storageUrl.path
        return databaseUrlPath
    }
    var doesStoragePathExist: Bool {
        return FileManager.default.fileExists(atPath: storagePath)
    }

    init(appId: String) {
        self.appId = appId
    }

    deinit {
        MiniAppLogger.d("🔑 Secure Storage Database: deinit")
    }

    func setup() throws {
        do {
            let queue = try Connection(storagePath)
            self.dbQueue = queue

            try (storageUrl as NSURL)
                 .setResourceValue(URLFileProtection.complete, forKey: .fileProtectionKey)

            do {
                try Entry.migrate(database: queue)
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
        guard doesStoragePathExist else {
            completion?(.storageUnavailable)
            return
        }
        do {
            let queue = try Connection(storagePath)
            self.dbQueue = queue
            completion?(nil)
        } catch {
            MiniAppLogger.d(error.localizedDescription)
            completion?(.storageIOError)
        }
    }

    func unload() throws {
        guard let dbQueue = dbQueue else { return }
        let closeResult = sqlite3_close(dbQueue.handle)
        if closeResult != SQLITE_OK {
            MiniAppLogger.d("🔑 Could not close datbase connection - \(closeResult)")
        } else {
            MiniAppLogger.d("🔑 Closed datbase connection")
        }
        self.dbQueue = nil
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
        if !doesStoragePathExist {
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

    func vacuum() throws {
        try dbQueue?.vacuum()
    }
}
