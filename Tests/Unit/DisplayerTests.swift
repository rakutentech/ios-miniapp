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
            context("when invalid file URL of a mini app is passed") {
                it("will return nil") {
                    let miniAppDisplayer = Displayer()
                    guard let url = URL(string: "https://example.com") else {
                        return
                    }
                    let miniAppView = miniAppDisplayer.getMiniAppView(miniAppPath: url)
                    expect(miniAppView).toEventually(beNil())
                }
            }
        }
    }
}
