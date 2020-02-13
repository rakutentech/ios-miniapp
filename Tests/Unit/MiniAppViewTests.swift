import Quick
import Nimble
@testable import MiniApp

class MiniAppViewTests: QuickSpec {

    override func spec() {
        describe("Mini App view") {
            context("when initialized with valid parameters") {
                it("will return MiniAppView object") {
                    guard let testFileURL = MockFile.createTestFile(fileName: "MiniApp.txt") else {
                        return
                    }
                    let miniAppView = MiniAppView(filePath: testFileURL)
                    expect(miniAppView).toEventually(beAnInstanceOf(MiniAppView.self))
                }
            }
            context("when initialized with invalid parameters") {
                it("will return nil") {
                    guard let url = URL(string: "https://example.com") else {
                          return
                    }
                    let miniAppView = MiniAppView(filePath: url)
                    expect(miniAppView).toEventually(beNil())
                }
            }
        }
    }
}
