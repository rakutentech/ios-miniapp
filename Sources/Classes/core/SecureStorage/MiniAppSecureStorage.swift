import Foundation
import CryptoKit

class MiniAppSecureStorage: MiniAppSecureStorageDelegate {

    /// miniapp id related to the store
    let appId: String

    /// file size defined in bytes
    var fileSizeLimit: UInt64

    /// state if the storage is currently loading
    var isStoreLoading: Bool = false

    static var storageName: String { return "securestorage" }

    let database: MiniAppSecureStorageDatabase

    init(
        appId: String,
        storageMaxSizeInBytes: UInt64? = nil,
        database: MiniAppSecureStorageDatabase? = nil
    ) {
        self.appId = appId
        self.fileSizeLimit = storageMaxSizeInBytes ?? 2_000_000
        self.database = database ?? MiniAppSecureStorageSqliteDatabase(appId: appId, fileSizeLimit: fileSizeLimit)
    }

    deinit {
        MiniAppLogger.d("🔑 Secure Storage: deinit")
    }

    // MARK: - Load/Unload
    func loadStorage(completion: ((Bool) -> Void)? = nil) {
        isStoreLoading = true
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.database.load(completion: { [weak self] error in
                self?.isStoreLoading = false
                guard error == nil else {
                    DispatchQueue.main.async {
                        completion?(false)
                    }
                    return
                }
                DispatchQueue.main.async {
                    completion?(true)
                }
            })
        }
    }

    func unloadStorage() {
        try? database.unload()
    }

    // MARK: - Actions
    func get(key: String) throws -> String? {
        return try database.get(key: key)
    }

    func set(dict: [String: String], completion: ((Result<Bool, MiniAppSecureStorageError>) -> Void)? = nil) {
        guard database.storageFileSize < fileSizeLimit else {
            completion?(.failure(.storageFullError))
            return
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                try self?.database.set(dict: dict)
                try self?.database.save(completion: { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            completion?(.success(true))
                        case let .failure(error):
                            completion?(.failure(error))
                        }
                    }
                })
            } catch let error {
                DispatchQueue.main.async {
                    MiniAppLogger.d(error.localizedDescription)
                    if let error = error as? MiniAppSecureStorageError {
                        completion?(.failure(error))
                    } else {
                        completion?(.failure(.storageIOError))
                    }
                }
                return
            }
        }
    }

    func remove(keys: [String], completion: ((Result<Bool, MiniAppSecureStorageError>) -> Void)? = nil) {
        guard database.isStoreAvailable else {
            completion?(.failure(MiniAppSecureStorageError.storageUnavailable))
            return
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                try self?.database.remove(keys: keys)
                try self?.database.save(completion: { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            completion?(.success(true))
                        case let .failure(error):
                            completion?(.failure(error))
                        }
                    }
                })
            } catch let error {
                DispatchQueue.main.async {
                    completion?(.failure((error as? MiniAppSecureStorageError) ?? .storageIOError))
                }
            }
        }
    }

    // MARK: - Wipe
    // MARK: Wipe all secure storages
    internal static func wipeSecureStorages() throws {
        MiniAppLogger.d("🔑 Secure Storage: destroy")
        try MiniAppSecureStorageSqliteDatabase.wipe()
    }

    // MARK: Wipe storage for MiniApp ID
    internal static func wipeSecureStorage(for miniAppId: String) throws {
        try MiniAppSecureStorageSqliteDatabase.wipe(for: miniAppId)
    }

    func clearSecureStorage() throws {
        database.clear { result in
            switch result {
            case .success:
                MiniAppLogger.d("🔑 Secure Storage: cleared")
            case .failure:
                MiniAppLogger.d("🔑 Secure Storage: clear failed")
            }
        }
    }

    // MARK: - Size
    func size() -> MiniAppSecureStorageSize {
        let storageFileSize = database.storageFileSize >= fileSizeLimit ? fileSizeLimit : database.storageFileSize
        return MiniAppSecureStorageSize(used: storageFileSize, max: fileSizeLimit)
    }
}

// MARK: - Notifications
extension MiniAppSecureStorage {
    static func sendLoadStorageReady(miniAppId: String, miniAppVersion: String) {
        NotificationCenter.default.sendCustomEvent(
            MiniAppEvent.Event(
                miniAppId: miniAppId,
                miniAppVersion: miniAppVersion,
                type: .secureStorageReady,
                comment: "MiniApp Secure Storage Ready"
            )
        )
    }

    static func sendLoadStorageError(miniAppId: String, miniAppVersion: String) {
        NotificationCenter.default.sendCustomEvent(
            MiniAppEvent.Event(
                miniAppId: miniAppId,
                miniAppVersion: miniAppVersion,
                type: .secureStorageError,
                comment: "MiniApp Secure Storage Error"
            )
        )
    }
}
