import XCTest
@testable import MiniApp

// swiftlint:disable file_length
class MiniAppSecureStorageTests: XCTestCase {

    enum TestError: Error {
        case storageShouldNotExist
    }

    let miniAppId = "test-1234"

    var miniAppPath: URL {
        let cachePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let path = cachePath.appendingPathComponent("/MiniApp").appendingPathComponent("/\(miniAppId)")
        return path
    }

    override class func setUp() {
        super.setUp()
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        do {
            try MiniAppSecureStorage.wipeSecureStorages()
        } catch {
            print("could not wipe storages")
        }
        guard FileManager.default.fileExists(atPath: miniAppPath.appendingPathComponent("securestorage.sqlite").path) == false
        else {
            throw TestError.storageShouldNotExist
        }
    }

    func setupStorage(storageMaxSizeInBytes: UInt64? = nil) throws -> MiniAppSecureStorage {
        let storage = MiniAppSecureStorage(appId: miniAppId, storageMaxSizeInBytes: storageMaxSizeInBytes)
        try storage.database.setup()
        return storage
    }

    // MARK: - Setup
    func testSetup_LoadStorage() {
        let expectation = XCTestExpectation(description: #function)

        let storage = MiniAppSecureStorage(appId: miniAppId)
        do {
            try storage.database.setup()
        } catch {
            XCTFail(error.localizedDescription)
        }

        var didLoadStorage = false
        storage.loadStorage { success in
            didLoadStorage = success
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3.0)

        XCTAssertTrue(didLoadStorage)
    }

    func testSetup_LoadStorage_WithSet() {
        let expectation = XCTestExpectation(description: #function)

        let storage = MiniAppSecureStorage(appId: miniAppId)

        var didLoadStorage = false
        storage.set(dict: ["test1": "value1"]) { result in
            switch result {
            case .success:
                storage.loadStorage { success in
                    didLoadStorage = success
                    expectation.fulfill()
                }
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }

        wait(for: [expectation], timeout: 3.0)

        XCTAssertTrue(didLoadStorage)
    }

    // MARK: - Unload Storage
    func testSetup_UnloadStorage() throws {
        let expectation = XCTestExpectation(description: #function)

        let storage = try setupStorage()

        var didLoadStorage = false
        storage.loadStorage { success in
            didLoadStorage = success
            storage.set(dict: ["test1": "test1Value"]) { result in
                switch result {
                case .success:
                    storage.unloadStorage()
                    expectation.fulfill()
                case let .failure(error):
                    XCTFail(error.localizedDescription)
                }
            }
        }

        wait(for: [expectation], timeout: 3.0)

        XCTAssertEqual(didLoadStorage, true)
        let testValue = try? storage.get(key: "test1")
        XCTAssertNil(testValue)
    }

    func testSetup_UnloadedStorage_Remove() {
        let expectation = XCTestExpectation(description: #function)

        let storage = MiniAppSecureStorage(appId: miniAppId)

        let testValue = try? storage.get(key: "test1")
        XCTAssertNil(testValue)

        var removeError: Error?
        storage.remove(keys: ["test1"]) { result in
            switch result {
            case .success:
                XCTFail("should not be able to set values")
            case let .failure(error):
                removeError = error
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 3.0)

        XCTAssertNotNil(removeError)
    }

    func testSetup_UnloadedStorage_WithoutSetup() {
        let expectation = XCTestExpectation(description: #function)
        let storage = MiniAppSecureStorage(appId: miniAppId)
        var didLoadStorage: Bool?
        storage.loadStorage { success in
            didLoadStorage = success
            expectation.fulfill()
        }
        XCTAssertEqual(didLoadStorage, false)
    }

    // MARK: - Set Values
    func testData_SetValues() throws {
        let expectation = XCTestExpectation(description: #function)
        let storage = try setupStorage()

        storage.loadStorage { success in
            storage.set(dict: [
                "test1": "test1Value",
                "test2": "test2Value",
                "test3": "test3Value"
            ]) { result in
                switch result {
                case .success:
                    expectation.fulfill()
                case let .failure(error):
                    XCTFail(error.localizedDescription)
                }
            }
        }

        wait(for: [expectation], timeout: 3.0)

        let test1 = try? storage.get(key: "test1")
        XCTAssertEqual(test1, "test1Value")
        let test2 = try? storage.get(key: "test2")
        XCTAssertEqual(test2, "test2Value")
        let test3 = try? storage.get(key: "test3")
        XCTAssertEqual(test3, "test3Value")
    }

    func testData_SetThenRemoveValues() throws {
        let setExpectation = XCTestExpectation(description: #function + "_set")
        let storage = try setupStorage()

        storage.loadStorage { success in
            storage.set(dict: [
                "test1": "test1Value",
                "test2": "test2Value"
            ]) { result in
                switch result {
                case .success:
                    setExpectation.fulfill()
                case let .failure(error):
                    XCTFail(error.localizedDescription)
                }
            }
        }

        wait(for: [setExpectation], timeout: 3.0)

        let setTest1 = try? storage.get(key: "test1")
        XCTAssertEqual(setTest1, "test1Value")
        let setTest2 = try? storage.get(key: "test2")
        XCTAssertEqual(setTest2, "test2Value")

        let removeExpectation = XCTestExpectation(description: #function + "remove")
        storage.remove(keys: ["test1", "test2"], completion: { removeResult in
            switch removeResult {
            case .success:
                removeExpectation.fulfill()
            case let .failure(error):
                XCTFail(error.localizedDescription)
            }
        })

        wait(for: [removeExpectation], timeout: 3.0)

        let test1 = try? storage.get(key: "test1")
        XCTAssertNil(test1)
        let test2 = try? storage.get(key: "test2")
        XCTAssertNil(test2)
    }

    func testData_SetValues_5k() throws {
        let expectation = XCTestExpectation(description: #function)
        let storage = try setupStorage()

        var dict: [String: String] = [:]
        (1...5_000).forEach({ dict[String($0)] = String($0) })

        storage.loadStorage { success in
            storage.set(dict: dict) { result in
                switch result {
                case .success:
                    expectation.fulfill()
                case let .failure(error):
                    XCTFail(error.localizedDescription)
                }
            }
        }

        wait(for: [expectation], timeout: 10.0)

        XCTAssertGreaterThan(storage.size().used, 125_000)
        XCTAssertEqual(Int((try? storage.get(key: "1")) ?? ""), 1)
        XCTAssertEqual(Int((try? storage.get(key: "100")) ?? ""), 100)
        XCTAssertEqual(Int((try? storage.get(key: "5000")) ?? ""), 5000)
    }

    func testData_SetThenRemoveValues_5k() throws {
        let setExpectation = XCTestExpectation(description: #function)
        let storage = try setupStorage()

        var dict: [String: String] = [:]
        (1...5_000).forEach({ dict[String($0)] = String($0) })

        storage.loadStorage { success in
            storage.set(dict: dict) { result in
                switch result {
                case .success:
                    setExpectation.fulfill()
                case let .failure(error):
                    XCTFail(error.localizedDescription)
                }
            }
        }

        wait(for: [setExpectation], timeout: 10.0)

        XCTAssertEqual(Int((try? storage.get(key: "1")) ?? ""), 1)
        XCTAssertEqual(Int((try? storage.get(key: "100")) ?? ""), 100)
        XCTAssertEqual(Int((try? storage.get(key: "5000")) ?? ""), 5000)

        let removeExpectation = XCTestExpectation(description: #function)
        storage.remove(keys: dict.keys.map({ $0 })) { result in
            switch result {
            case .success:
                removeExpectation.fulfill()
            case let .failure(error):
                XCTFail(error.localizedDescription)
            }
        }

        wait(for: [removeExpectation], timeout: 10.0)

        XCTAssertNil(try? storage.get(key: "1"))
        XCTAssertNil(try? storage.get(key: "100"))
        XCTAssertNil(try? storage.get(key: "5000"))

        XCTAssertEqual(storage.size().used, 12_288)
    }

    func testData_RepeatingUpdates_Size() throws {
        let expectation = XCTestExpectation(description: #function)
        let storage = try setupStorage()

        var firstInsertSize: UInt64 = 0

        var dict: [String: String] = [:]
        (1...1_000).forEach({ dict[String($0)] = "1_\($0)" })

        storage.loadStorage { success in
            storage.set(dict: dict) { result in
                switch result {
                case .success:
                    firstInsertSize = storage.size().used
                    expectation.fulfill()
                case let .failure(error):
                    XCTFail(error.localizedDescription)
                }
            }
        }

        wait(for: [expectation], timeout: 10.0)
        XCTAssertEqual(storage.size().used, firstInsertSize)

        let expectation2 = XCTestExpectation(description: #function)

        var dict2: [String: String] = [:]
        (1...1_000).forEach({ dict2[String($0)] = "2_\($0)" })

        storage.set(dict: dict2) { result in
            switch result {
            case .success:
                expectation2.fulfill()
            case let .failure(error):
                XCTFail(error.localizedDescription)
            }
        }

        wait(for: [expectation2], timeout: 10.0)
        XCTAssertEqual(storage.size().used, firstInsertSize)

        let expectation3 = XCTestExpectation(description: #function)

        var dict3: [String: String] = [:]
        (1...1_000).forEach({ dict3[String($0)] = "3_\($0)" })

        storage.set(dict: dict3) { result in
            switch result {
            case .success:
                expectation3.fulfill()
            case let .failure(error):
                XCTFail(error.localizedDescription)
            }
        }

        wait(for: [expectation3], timeout: 10.0)
        XCTAssertEqual(storage.size().used, firstInsertSize)
    }

    // MARK: - Size
    func testSize() throws {
        let expectation = XCTestExpectation(description: #function)
        let storage = try setupStorage()

        var storageSize: UInt64 = 0
        storage.loadStorage { _ in
            storageSize = storage.database.storageFileSize
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3.0)
        XCTAssertEqual(storageSize, 12_288)
    }

    func testSize_ExceedStorage() throws {
        let expectation = XCTestExpectation(description: #function)
        let storage = try setupStorage(storageMaxSizeInBytes: 43)

        var resultError: MiniAppSecureStorageError?
        storage.loadStorage { success in
            let values = [
                "test1": "test1Value",
                "test2": "test2Value",
                "test3": "test3Value",
                "test4": "test4Value"
            ]
            storage.set(dict: values) { result in
                switch result {
                case .success:
                    XCTFail("should not exceed")
                case .failure(let error):
                    resultError = error
                    expectation.fulfill()
                }
            }
        }
        XCTAssertEqual(resultError, MiniAppSecureStorageError.storageFullError)
    }

    // MARK: - Clear
    func testClear_ClearData() throws {
        let expectation = XCTestExpectation(description: #function)
        let storage = try setupStorage()

        storage.set(dict: [
            "test1": "value1"
        ]) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case let .failure(error):
                XCTFail("set should be successful; \(error.localizedDescription)")
            }
        }

        wait(for: [expectation], timeout: 3.0)

        let valueBefore = try? storage.get(key: "test1")
        XCTAssertEqual(valueBefore, "value1")

        try? storage.clearSecureStorage()

        let valueAfter = try? storage.get(key: "test1")
        XCTAssertNil(valueAfter)
    }

    func testClear_Wipe() throws {
        _ = try setupStorage()
        let secureStorageUrl = FileManager.getMiniAppDirectory(with: miniAppId).appendingPathComponent("/securestorage.sqlite")
        try? MiniAppSecureStorage.wipeSecureStorages()
        XCTAssertEqual(FileManager.default.fileExists(atPath: secureStorageUrl.path), false)
    }

    func testClear_ClearData_Size() throws {
        let expectation = XCTestExpectation(description: #function)
        let storage = try setupStorage()

        var dict: [String: String] = [:]
        (1...1_000).forEach({ dict[String($0)] = String($0) })

        storage.loadStorage { success in
            storage.set(dict: dict) { result in
                switch result {
                case .success:
                    expectation.fulfill()
                case let .failure(error):
                    XCTFail(error.localizedDescription)
                }
            }
        }

        wait(for: [expectation], timeout: 10.0)
        XCTAssertGreaterThan(storage.size().used, 12_288)

        try? storage.clearSecureStorage()

        XCTAssertEqual(storage.size().used, 12_288)
    }

    // MARK: - Error
    func testError_StorageUnavailable() {
        let storage = MiniAppSecureStorage(appId: miniAppId)
        do {
            _ = try storage.get(key: "test1")
        } catch let error {
            guard let error = error as? MiniAppSecureStorageError else {
                XCTFail("should be a secure storage error")
                return
            }
            XCTAssertEqual(error.name, MiniAppSecureStorageError.storageUnavailable.name)
            XCTAssertEqual(error.description, MiniAppSecureStorageError.storageUnavailable.description)
        }
    }

    func testError_StorageFull() {
        let storage = MiniAppSecureStorage(appId: miniAppId, storageMaxSizeInBytes: 0)
        storage.set(dict: ["test1": "value1"], completion: { result in
            switch result {
            case .success:
                XCTFail("should not succeed")
            case let .failure(error):
                XCTAssertEqual(error.name, MiniAppSecureStorageError.storageFullError.name)
                XCTAssertEqual(error.description, MiniAppSecureStorageError.storageFullError.description)
            }
        })
    }

    func testError_StorageIO() {
        do {
            try MiniAppSecureStorageSqliteDatabase.wipe(for: "test-123456")
        } catch let error {
            guard let error = error as? MiniAppSecureStorageError else {
                XCTFail("should be a secure storage error")
                return
            }
            XCTAssertEqual(error.name, MiniAppSecureStorageError.storageIOError.name)
            XCTAssertEqual(error.description, MiniAppSecureStorageError.storageIOError.description)
        }
    }
}
