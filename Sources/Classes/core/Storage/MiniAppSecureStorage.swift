import Foundation
import CryptoKit

class MiniAppSecureStorage {

    let appId: String
    private var storage: [String: String]?
    private var isStoreLoading: Bool = false
    private var isBusy: Bool = false

    private static let storageName: String = "securestorage"
    static var storageFullName: String { return storageName + ".plist" }

    init(appId: String) {
        self.appId = appId
        try? setup(appId: appId)
    }

    private func setup(appId: String) throws {
        let secureStoragePath = MiniAppSecureStorage.storagePath(appId: appId)
        MiniAppLogger.d("🔑 Secure Storage: \(secureStoragePath)")
        guard
            !FileManager.default.fileExists(atPath: secureStoragePath.path)
        else {
            MiniAppLogger.d("🔑 Secure Storage: store exists")
            return
        }
        MiniAppLogger.d("🔑 Secure Storage: store does not exist")
        MiniAppLogger.d("🔑 Secure Storage: write to disk")
        let secureStorage: [String: String] = [:]
        let secureStorageData = try PropertyListEncoder().encode(secureStorage)
        try secureStorageData.write(to: secureStoragePath, options: .completeFileProtectionUnlessOpen)
    }

    // MARK: - Load/Unload
    func loadStorage(completion: ((Bool) -> Void)? = nil) {
        isStoreLoading = true
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let strongSelf = self else { return }
            let loadedStorage = FileManager.default.retrievePlist(
                MiniAppSecureStorage.storageFullName,
                from: MiniAppSecureStorage.miniAppPath(appId: strongSelf.appId),
                as: [String: String].self
            )
            DispatchQueue.main.async {
                strongSelf.isStoreLoading = false
                strongSelf.storage = loadedStorage
                completion?(loadedStorage != nil)
            }
        }
    }

    func unloadStorage() {
        self.storage = nil
    }

    // MARK: - Actions
    func get(key: String) throws -> String? {
        guard let storage = storage else { throw MiniAppSecureStorageError.storageNotExistent }
        MiniAppLogger.d("🔑 Secure Storage: get '\(key)'")
        return storage[key]
    }

    func set(dict: [String: String], completion: ((Result<Bool, Error>) -> Void)? = nil) {
        guard storage != nil else {
            completion?(.failure(MiniAppSecureStorageError.storageNotExistent))
            return
        }
        guard !isBusy else {
            completion?(.failure(MiniAppSecureStorageError.storageBusyProcessing))
            return
        }
        isBusy = true
        for (key, value) in dict {
            MiniAppLogger.d("🔑 Secure Storage: set '\(key)'")
            storage?[key] = value
        }

        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let strongSelf = self else { return }
            do {
                try strongSelf.saveStoreToDisk()
            } catch let error {
                strongSelf.isBusy = false
                completion?(.failure(error))
                return
            }
            DispatchQueue.main.async {
                strongSelf.isBusy = false
                completion?(.success(true))
                MiniAppLogger.d("🔑 Secure Storage: set finish")
            }
        }
    }

    func remove(keys: [String], completion: ((Result<Bool, Error>) -> Void)? = nil) {
        guard storage != nil else {
            completion?(.failure(MiniAppSecureStorageError.storageNotExistent))
            return
        }
        guard !isBusy else {
            completion?(.failure(MiniAppSecureStorageError.storageBusyProcessing))
            return
        }
        isBusy = true
        for key in keys {
            MiniAppLogger.d("🔑 Secure Storage: remove '\(key)'")
            storage?.removeValue(forKey: key)
        }

        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let strongSelf = self else { return }
            do {
                try strongSelf.saveStoreToDisk()
            } catch let error {
                strongSelf.isBusy = false
                completion?(.failure(error))
                return
            }
            DispatchQueue.main.async {
                strongSelf.isBusy = false
                completion?(.success(true))
            }
        }
    }

    // MARK: - Internal
    private func loadLocalStorage() -> [String: String]? {
        let secureStoragePath = MiniAppSecureStorage.miniAppPath(appId: appId)
        let secureStorageName = MiniAppSecureStorage.storageName + ".plist"
        let loadedStorage = FileManager.default.retrievePlist(secureStorageName, from: secureStoragePath, as: [String: String].self)
        return loadedStorage
    }

    private static func miniAppPath(appId: String) -> URL {
        return FileManager.getMiniAppDirectory(with: appId)
    }

    private static func storagePath(appId: String) -> URL {
        return FileManager.getMiniAppDirectory(with: appId).appendingPathComponent("/\(storageName).plist")
    }

    private func saveStoreToDisk(completion: (() -> Void)? = nil) throws {
        guard let storage = storage else { throw MiniAppSecureStorageError.storageNotExistent }
        MiniAppLogger.d("🔑 Secure Storage: write store to disk")
        let secureStoragePath = MiniAppSecureStorage.storagePath(appId: appId)
        let secureStorageData = try PropertyListEncoder().encode(storage)
        try secureStorageData.write(to: secureStoragePath, options: .completeFileProtectionUnlessOpen)
        MiniAppLogger.d("🔑 Secure Storage: write store to disk completed")
    }

    // MARK: - Clear
    static func clearSecureStorage() throws {
        MiniAppLogger.d("🔑 Secure Storage: destroy")
        let cachePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let miniAppPath = cachePath.appendingPathComponent("/MiniApp/")
        guard let contentNames = try? FileManager.default.contentsOfDirectory(atPath: miniAppPath.path) else { return }
        for name in contentNames {
            let url = miniAppPath.appendingPathComponent("/" + name)
            if let isDirectory = (try url.resourceValues(forKeys: [.isDirectoryKey])).isDirectory, isDirectory {
                do {
                    try FileManager.default.removeItem(at: url.appendingPathComponent("/" + storageFullName))
                    MiniAppLogger.d("🔑 Secure Storage: destroyed storaged for \(name)")
                } catch {
                    MiniAppLogger.d("🔑 Secure Storage: could not destroy storaged for \(name)")
                }
            } else {
                MiniAppLogger.d("🔑 Secure Storage: ignored \(name)")
            }
        }
    }

    static func clearSecureStorage(for miniAppId: String) throws {
        MiniAppLogger.d("🔑 Secure Storage: destroy")
        try FileManager.default.removeItem(at: storagePath(appId: miniAppId))
    }

    static func size(for miniAppId: String) throws -> UInt64 {
        let fileSize = MiniAppSecureStorage.storagePath(appId: miniAppId).fileSize
        guard fileSize > 0 else { throw MiniAppSecureStorageError.storageFileEmpty }
        MiniAppLogger.d("🔑 Secure Storage: size -> \(fileSize)")
        return fileSize
    }
}

enum MiniAppSecureStorageError: Error {
    case storageNotExistent
    case storageFileEmpty
    case storageBusyProcessing
}
