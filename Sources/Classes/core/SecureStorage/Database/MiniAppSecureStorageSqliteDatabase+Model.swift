import Foundation
import SQLite

extension MiniAppSecureStorageSqliteDatabase {

    struct Entry: Codable {

        var key: String
        var value: String

        // MARK: - Database
        static let entries = Table("entries")
        static let key = Expression<String>("key")
        static let value = Expression<String>("value")

        static func migrate(database: Connection) throws {
            try database.run(entries.create { table in
                table.column(key, primaryKey: true)
                table.column(value)
            })
        }

        static func find(database: Connection, key: String) throws -> Entry? {
            for entry in try database.prepare(entries.filter(Self.key == key)) {
                return Entry(key: entry[Self.key], value: entry[Self.value])
            }
            return nil
        }

        static func upsert(database: Connection, key: String, value: String) throws {
            let upsert = entries.upsert(Self.key <- key, Self.value <- value, onConflictOf: Self.key)
            _ = try database.run(upsert)
        }

        static func delete(database: Connection, key: String) throws {
            let delete = entries.filter(Self.key == key).delete()
            _ = try database.run(delete)
        }

        static func deleteAll(database: Connection) throws {
            let delete = entries.delete()
            _ = try database.run(delete)
        }
    }

}
