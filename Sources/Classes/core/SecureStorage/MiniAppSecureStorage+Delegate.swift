import Foundation

protocol MiniAppSecureStorageDelegate: AnyObject {
    /// retrieve a value from the storage
    func get(key: String) throws -> String?

    /// add a key/value set and save it to the disk
    func set(dict: [String: String], completion: ((Result<Bool, MiniAppSecureStorageError>) -> Void)?)

    /// remove a set of keys from the storage and save it to disk
    func remove(keys: [String], completion: ((Result<Bool, MiniAppSecureStorageError>) -> Void)?)

    /// retrieve the storage size in bytes
    func size() -> MiniAppSecureStorageSize

    /// clears the current storage
    func clearSecureStorage() throws
}
