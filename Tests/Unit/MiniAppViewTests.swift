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
                it("will return same frame sizes") {
                    guard let testFileURL = MockFile.createTestFile(fileName: "MiniApp.txt") else {
                        return
                    }
                    let viewFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    let miniAppView = MiniAppView(filePath: testFileURL)
                    miniAppView.frame = viewFrame
                    expect(miniAppView.frame).toEventually(equal(viewFrame))
                }
            }
        }
    }
}
