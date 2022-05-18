import Foundation
import CoreData
import GRDB

extension MiniAppSecureStorageSqliteDatabase {
    struct Entry: Codable, FetchableRecord, PersistableRecord {
        static var databaseTableName: String { return "entries" }
        var key: String
        var value: String
    }
}
