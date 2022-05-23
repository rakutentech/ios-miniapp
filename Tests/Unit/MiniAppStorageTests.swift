import Quick
import Nimble
@testable import MiniApp

// swiftlint:disable function_body_length cyclomatic_complexity
class MiniAppStorageTests: QuickSpec {

    override func spec() {
        describe("mini app storage") {
            context("when there is an error cleaning storage") {
                it("it won't crash") {
                    let storage = MiniAppStorage()
                    storage.cleanVersions(for: "test", differentFrom: "test", status: MiniAppStatus())
                }
            }
            context("when there is an error saving in storage") {
                it("it won't crash and return an error") {
                    let storage = MiniAppStorage()
                    let url = MockFile.createTestFile(fileName: "tmp")
                    try? FileManager.default.removeItem(at: url!)
                    let error = storage.save(sourcePath: url!, destinationPath: url!)
                    expect(error).toNot(beNil())
                }
            }
        }

        describe("miniapp secure storage") {

            let miniAppId = "test-1234"

            var miniAppPath: URL {
                let cachePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
                let path = cachePath.appendingPathComponent("/MiniApp").appendingPathComponent("/\(miniAppId)")
                return path
            }

            beforeEach {
                try? MiniAppSecureStorage.wipeSecureStorages()
                try? FileManager.default.createDirectory(at: miniAppPath, withIntermediateDirectories: true, attributes: nil)
            }

            context("storage loading") {

                it("will load the storage") {
                    let storage = MiniAppSecureStorage(appId: miniAppId)
                    do {
                        try storage.database.setup()
                    } catch {
                        fail(error.localizedDescription)
                    }
                    var didLoadStorage = false
                    storage.loadStorage { success in
                        didLoadStorage = success
                    }
                    expect(didLoadStorage).toEventually(beTrue())
                }

                it("will unload the storage") {
                    let storage = MiniAppSecureStorage(appId: miniAppId)
                    do {
                        try storage.database.setup()
                    } catch {
                        fail(error.localizedDescription)
                    }
                    var didLoadStorage = false
                    storage.loadStorage { success in
                        didLoadStorage = success
                        storage.set(dict: ["test1": "test1Value"]) { result in
                            switch result {
                            case .success:
                                storage.unloadStorage()
                                let test1 = try? storage.get(key: "test1")
                                expect(test1).to(beNil())
                            case let .failure(error):
                                fail(error.localizedDescription)
                            }
                        }
                    }
                    expect(didLoadStorage).toEventually(beTrue())
                }

                it("will load the storage after set") {
                    let storage = MiniAppSecureStorage(appId: miniAppId)

                    let exists = FileManager.default.fileExists(atPath: miniAppPath.path + "/" + storage.database.storageFullName)
                    guard !exists else {
                        fail("storage should not exist")
                        return
                    }

                    storage.set(dict: ["test1": "value1"]) { result in
                        switch result {
                        case .success:
                            var didLoadStorage = false
                            storage.loadStorage { success in
                                didLoadStorage = success
                            }
                            expect(didLoadStorage).toEventually(beTrue())
                        case .failure(let error):
                            fail(error.localizedDescription)
                        }
                    }
                }

                it("will not load the storage and should not be able to read and remove") {
                    let storage = MiniAppSecureStorage(appId: miniAppId)

                    let testValue = try? storage.get(key: "test1")
                    expect(testValue).to(beNil())

                    var removeError: Error?
                    storage.remove(keys: ["test1"]) { result in
                        switch result {
                        case .success:
                            fail("should not be able to set values")
                        case let .failure(error):
                            removeError = error
                        }
                    }
                    expect(removeError).toEventuallyNot(beNil())
                }

                it("will fail to load the storage without setup") {
                    let storage = MiniAppSecureStorage(appId: miniAppId)
                    var failedToLoad: Bool = false
                    storage.loadStorage { success in
                        failedToLoad = !success
                    }
                    expect(failedToLoad).to(beTrue())
                }
            }

            context("storage read/write") {
                it("will set some values") {
                    let storage = MiniAppSecureStorage(appId: miniAppId)
                    do {
                        try storage.database.setup()
                    } catch {
                        fail(error.localizedDescription)
                    }
                    var didLoadStorage = false
                    storage.loadStorage { success in
                        didLoadStorage = success
                        storage.set(dict: ["test1": "test1Value", "test2": "test2Value", "test3": "test3Value"]) { result in
                            switch result {
                            case .success:
                                let test1 = try? storage.get(key: "test1")
                                expect(test1).to(equal("test1Value"))
                                let test2 = try? storage.get(key: "test2")
                                expect(test2).to(equal("test2Value"))
                                let test3 = try? storage.get(key: "test3")
                                expect(test3).to(equal("test3Value"))
                            case let .failure(error):
                                fail(error.localizedDescription)
                            }
                        }
                    }
                    expect(didLoadStorage).toEventually(beTrue())
                }

                it("will set then remove some values") {
                    let storage = MiniAppSecureStorage(appId: miniAppId)
                    do {
                        try storage.database.setup()
                    } catch {
                        fail(error.localizedDescription)
                    }
                    var didLoadStorage = false
                    storage.loadStorage { success in
                        didLoadStorage = success
                        storage.set(dict: ["test1": "test1Value", "test2": "test2Value"]) { result in
                            switch result {
                            case .success:
                                storage.remove(keys: ["test1", "test2"], completion: { removeResult in
                                    switch removeResult {
                                    case .success:
                                        let test1 = try? storage.get(key: "test1")
                                        expect(test1).to(beNil())
                                        let test2 = try? storage.get(key: "test2")
                                        expect(test2).to(beNil())
                                    case let .failure(error):
                                        fail(error.localizedDescription)
                                    }
                                })
                            case let .failure(error):
                                fail(error.localizedDescription)
                            }
                        }
                    }
                    expect(didLoadStorage).toEventually(beTrue())
                }
            }

            context("storage size") {
                it("will calculate size for an empty storage") {
                    let storage = MiniAppSecureStorage(appId: miniAppId)
                    do {
                        try storage.database.setup()
                    } catch {
                        fail(error.localizedDescription)
                    }
                    var storageSize: UInt64 = 0
                    storage.loadStorage { _ in
                        storageSize = storage.database.storageFileSize
                    }
                    expect(storageSize).toEventually(equal(12288))
                }

                it("will exceed storage size and throw an error") {
                    let storage = MiniAppSecureStorage(appId: miniAppId, storageMaxSizeInBytes: 43)
                    do {
                        try storage.database.setup()
                    } catch {
                        fail(error.localizedDescription)
                    }
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
                                fail("should not exceed")
                            case .failure(let error):
                                resultError = error
                            }
                        }
                    }
                    expect(resultError).toEventually(equal(MiniAppSecureStorageError.storageFullError))
                }
            }

            context("clear / wipe") {
                it("will clear all data in secure storage") {
                    let storage = MiniAppSecureStorage(appId: miniAppId)
                    do {
                        try storage.database.setup()
                    } catch {
                        fail(error.localizedDescription)
                    }
                    storage.set(dict: ["test1": "value1"]) { result in
                        switch result {
                        case .success:
                            try? storage.clearSecureStorage()
                            expect(try? storage.get(key: "test1")).to(beNil())
                        case let .failure(error):
                            fail("set should be successful; \(error.localizedDescription)")
                        }
                    }
                }

                it("will wipe secure storage for miniapp") {
                    let secureStorageUrl = FileManager.getMiniAppDirectory(with: miniAppId).appendingPathComponent("/securestorage.plist")
                    try? MiniAppSecureStorage.wipeSecureStorages()
                    expect(FileManager.default.fileExists(atPath: secureStorageUrl.path)).to(beFalse())
                }
            }

            context("error") {
                it("should throw secure storage unvailable error") {
                    let storage = MiniAppSecureStorage(appId: miniAppId)
                    do {
                        _ = try storage.get(key: "test1")
                    } catch let error {
                        guard let error = error as? MiniAppSecureStorageError else {
                            fail("should be a secure storage error")
                            return
                        }
                        expect(error.name).to(equal(MiniAppSecureStorageError.storageUnvailable.name))
                        expect(error.description).to(equal(MiniAppSecureStorageError.storageUnvailable.description))
                    }
                }
                it("should throw secure storage full error") {
                    let storage = MiniAppSecureStorage(appId: miniAppId, storageMaxSizeInBytes: 0)
                    storage.set(dict: ["test1": "value1"], completion: { result in
                        switch result {
                        case .success:
                            fail("should not succeed")
                        case let .failure(error):
                            expect(error.name).to(equal(MiniAppSecureStorageError.storageFullError.name))
                            expect(error.description).to(equal(MiniAppSecureStorageError.storageFullError.description))
                        }
                    })
                }
                it("should throw secure storage io error") {
                    do {
                        try MiniAppSecureStorageSqliteDatabase.wipe(for: "test-123456")
                    } catch let error {
                        guard let error = error as? MiniAppSecureStorageError else {
                            fail("should be a secure storage error")
                            return
                        }
                        expect(error.name).to(equal(MiniAppSecureStorageError.storageIOError.name))
                        expect(error.description).to(equal(MiniAppSecureStorageError.storageIOError.description))
                    }
                }
            }
        }
    }
}
