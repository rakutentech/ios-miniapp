import Foundation

class MiniAppSecureStoragePlistDatabase: MiniAppSecureStorageDatabase {

    private var storage: [String: String]?

    var appId: String

    static let storageName: String = MiniAppSecureStorage.storageName
    static let storageNameExtension: String = "plist"
    static var storageFullName: String { return storageName + ".\(storageNameExtension)" }

    var isStoreAvailable: Bool {
        storage != nil
    }

    var storageFullName: String { return Self.storageFullName }

    init(appId: String) {
        self.appId = appId
        do {
            try setup()
        } catch {
            MiniAppLogger.d("🔑 Secure Storage: ❌❌❌ critical error setup did not complete")
        }
    }

    func setup() throws {
        let secureStoragePath = storagePath(appId: appId)
        guard
            !FileManager.default.fileExists(atPath: secureStoragePath.path)
        else {
            return
        }
        let secureStorage: [String: String] = [:]
        let secureStorageData = try PropertyListEncoder().encode(secureStorage)
        try secureStorageData.write(to: secureStoragePath, options: .completeFileProtectionUnlessOpen)
    }

    func load(completion: ((MiniAppSecureStorageError?) -> Void)? = nil) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let strongSelf = self else { return }
            let loadedStorage = FileManager.default.retrievePlist(
                MiniAppSecureStoragePlistDatabase.storageFullName,
                from: strongSelf.miniAppPath(appId: strongSelf.appId),
                as: [String: String].self
            )
            DispatchQueue.main.async {
                if let storage = loadedStorage {
                    strongSelf.storage = storage
                    completion?(nil)
                } else {
                    completion?(MiniAppSecureStorageError.storageIOError)
                }
            }
        }
    }

    func unload() throws {
        self.storage = nil
    }

    func get(key: String) throws -> String? {
        guard let storage = storage else { throw MiniAppSecureStorageError.storageUnvailable }
        MiniAppLogger.d("🔑 Secure Storage: get '\(key)'")
        return storage[key]
    }

    func set(dict: [String: String]) throws {
        for (key, value) in dict {
            self.storage?[key] = value
        }
    }

    func remove(keys: [String]) throws {
        for key in keys {
            storage?.removeValue(forKey: key)
        }
    }

    func save(completion: ((Result<Bool, MiniAppSecureStorageError>) -> Void)? = nil) throws {
        guard let storage = storage else { throw MiniAppSecureStorageError.storageUnvailable }
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let strongSelf = self else { return }
            do {
                MiniAppLogger.d("🔑 Secure Storage: write store to disk")
                let secureStoragePath = strongSelf.storagePath(appId: strongSelf.appId)
                let secureStorageData = try PropertyListEncoder().encode(storage)
                try secureStorageData.write(to: secureStoragePath, options: .completeFileProtectionUnlessOpen)
                MiniAppLogger.d("🔑 Secure Storage: write store to disk completed")

                DispatchQueue.main.async {
                    completion?(.success(true))
                }
            } catch let error {
                if let error = error as? MiniAppSecureStorageError {
                    completion?(.failure(error))
                } else {
                    completion?(.failure(.storageIOError))
                }
                return
            }
        }
    }

    func clear(completion: ((Result<Bool, MiniAppSecureStorageError>) -> Void)? = nil) {
        MiniAppLogger.d("🔑 Secure Storage: destroy")
        self.storage?.removeAll()
        try? self.save(completion: completion)
    }

    func storagePath(appId: String) -> URL {
        return FileManager.getMiniAppDirectory(with: appId).appendingPathComponent("/\(storageFullName)")
    }

    func miniAppPath(appId: String) -> URL {
        return FileManager.getMiniAppDirectory(with: appId)
    }
}
