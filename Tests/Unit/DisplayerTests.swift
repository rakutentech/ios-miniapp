import Quick
import Nimble
@testable import MiniApp

class DisplayerTests: QuickSpec {

    override func spec() {
        describe("get mini app view") {
            context("when valid URL of a mini app is passed") {
                it("will return MiniAppView") {
                    let miniAppDisplayer = Displayer()
                    guard let testFileURL = MockFile.createTestFile(fileName: "MiniApp.txt") else {
                        return
                    }
                    let miniAppView = miniAppDisplayer.getMiniAppView(miniAppPath: testFileURL)
                    expect(miniAppView).toEventually(beAnInstanceOf(MiniAppView.self))
                }
            }
            context("when invalid URL of a mini app is passed") {
                it("will return nil") {
                    let miniAppDisplayer = Displayer()
                    let miniAppView = miniAppDisplayer.getMiniAppView(miniAppPath: nil)
                    expect(miniAppView).toEventually(beNil())
                }
            }
        }
    }
}
