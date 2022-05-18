import Foundation
import CoreData

class MiniAppSecureStorageCoreDatabase: MiniAppSecureStorageDatabase {

    var appId: String

    static let storageName: String = MiniAppSecureStorage.storageName
    static let storageNameExtension: String = "sqlite"
    static var storageFullName: String { return storageName + ".\(storageNameExtension)" }

    private(set) var managedObjectContext: NSManagedObjectContext?
    private(set) var persistentStoreCoordinator: NSPersistentStoreCoordinator?

    private lazy var managedObjectModel: NSManagedObjectModel = {
        return SecureStorageEntry.managedObjectModel()
    }()

    var isStoreAvailable: Bool {
        return managedObjectContext != nil
    }

    var storageFullName: String { return Self.storageFullName }

    init(appId: String) {
        self.appId = appId
    }

    func load(completion: ((MiniAppSecureStorageError?) -> Void)?) {
        _ = managedObjectContext
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let databasePath = "/\(appId)/\(MiniAppSecureStorageCoreDatabase.storageFullName)"
        let databaseUrl = FileManager.getMiniAppFolderPath().appendingPathComponent(databasePath)
        guard let store = try?
            coordinator.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: databaseUrl,
                options: [NSPersistentStoreFileProtectionKey: FileProtectionType.complete]
            ),
            (try? store.loadMetadata()) != nil
        else {
            completion?(.storageIOError)
            return
        }

        persistentStoreCoordinator = coordinator

        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        managedObjectContext = context

        completion?(nil)
    }

    func unload() throws {
        managedObjectContext = nil
        persistentStoreCoordinator = nil
    }

    func find(for key: String) throws -> SecureStorageEntry? {
        guard let context = managedObjectContext else { throw MiniAppSecureStorageError.storageUnvailable }
        let request = NSFetchRequest<SecureStorageEntry>(entityName: "SecureStorageEntry")
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "key = %@", key)
        let result = try context.fetch(request)
        if result.count == 1 {
            return result[0]
        }
        return nil
    }

    func save(completion: ((Result<Bool, MiniAppSecureStorageError>) -> Void)? = nil) throws {
        guard let context = managedObjectContext else { throw MiniAppSecureStorageError.storageUnvailable }
        if context.hasChanges {
            try context.save()
            completion?(.success(true))
        } else {
            completion?(.failure(.storageIOError))
        }
    }

    func get(key: String) throws -> String? {
        return try find(for: key)?.value
    }

    func set(dict: [String: String]) throws {
        guard let context = managedObjectContext else { throw MiniAppSecureStorageError.storageUnvailable }
        for (key, value) in dict {
            if let existingEntry = try? find(for: key) {
                existingEntry.value = value
            } else {
                let entry = NSManagedObject(entity: SecureStorageEntry.entity(), insertInto: context)
                entry.setValue(key, forKey: "key")
                entry.setValue(value, forKey: "value")
            }
        }
    }

    func remove(keys: [String]) throws {
        guard let context = managedObjectContext else { throw MiniAppSecureStorageError.storageUnvailable }
        for key in keys {
            if let existingEntry = try find(for: key) {
                context.delete(existingEntry)
            } else {
                throw MiniAppSecureStorageError.storageIOError
            }
        }
    }

    func clear(completion: ((Result<Bool, MiniAppSecureStorageError>) -> Void)? = nil) {
        MiniAppLogger.d("🔑 Secure Storage: clear")
        guard let context = managedObjectContext else {
            completion?(.failure(MiniAppSecureStorageError.storageUnvailable))
            return
        }
        let request = NSFetchRequest<SecureStorageEntry>(entityName: "SecureStorageEntry")
        guard let result = try? context.fetch(request) else {
            completion?(.failure(.storageIOError))
            return
        }
        if !result.isEmpty {
            do {
                try remove(keys: result.map({ $0.key }))
                completion?(.success(true))
            } catch let error {
                completion?(.failure((error as? MiniAppSecureStorageError) ?? .storageIOError))
            }
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
