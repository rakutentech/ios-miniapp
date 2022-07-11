import Quick
import Nimble
import Foundation
@testable import MiniApp

class MiniAppStorageTests: QuickSpec {

    override func spec() {
        describe("mini app storage") {
            context("when there is an error cleaning storage") {
                it("it won't crash") {
                    MiniAppStorage.cleanVersions(for: "test", differentFrom: "test", status: MiniAppStatus())
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
    }

}
