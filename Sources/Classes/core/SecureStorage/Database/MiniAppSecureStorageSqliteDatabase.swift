import Foundation
import SQLite
import SQLite3

class MiniAppSecureStorageSqliteDatabase: MiniAppSecureStorageDatabase {

    var appId: String
    var fileSizeLimit: UInt64

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

    init(appId: String, fileSizeLimit: UInt64) {
        self.appId = appId
        self.fileSizeLimit = fileSizeLimit
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

        let limiter = determineBatchSetLimiter(count: dict.count)
        for (index, pair) in dict.enumerated() {
            if index % limiter == 0 {
                guard storageFileSize < fileSizeLimit else {
                    throw MiniAppSecureStorageError.storageFullError
                }
            }
            let upsertResult = try Entry.upsert(database: dbQueue, key: pair.key, value: pair.value)
            MiniAppLogger.d("🔑 Secure Storage: upsert -> \(upsertResult)")
        }
    }

    func remove(keys: [String]) throws {
        guard let dbQueue = dbQueue else { throw MiniAppSecureStorageError.storageUnavailable }
        for key in keys {
            let deleteResult = try Entry.delete(database: dbQueue, key: key)
            guard deleteResult == 1 else { throw MiniAppSecureStorageError.storageIOError }
            MiniAppLogger.d("🔑 Secure Storage: delete -> \(deleteResult == 0 ? false : true)")
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
            try dbQueue.vacuum()
            completion?(.success(true))
        } catch {
            completion?(.failure(.storageIOError))
        }
    }

    func determineBatchSetLimiter(count: Int) -> Int {
        switch count {
        case 0..<100:
            return 1
        case 100..<5_000:
            return 25
        case 5_000..<25_000:
            return 100
        case 25_000..<50_000:
            return 200
        case 50_000..<100_000:
            return 250
        case 100_000..<1_000_000:
            return 500
        case let num where num > 1_000_000:
            return 1000
        default:
            return 1
        }
    }

    func vacuum() throws {
        try dbQueue?.vacuum()
    }
}
