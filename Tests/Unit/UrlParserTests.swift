import Quick
import Nimble
@testable import MiniApp

class UrlParserTests: QuickSpec {
    override func spec() {
        describe("Url parser") {
            context("when parseForFileDirectory is called with valid url") {
                it("will returns the path to store the file") {
                    let urlString = "https://www.example.com/version/rak0123/img/onload/file.png"
                    let path = UrlParser.parseForFileDirectory(with: urlString)
                    expect(path).toEventually(equal("img/onload/file.png"))
                }
            }
            context("when parseForFileDirectory is called with invalid url") {
                it("will return nil") {
                    let urlString = "https://www.example.com/mini-ver/rak0123/img/onload/file.png"
                    let path = UrlParser.parseForFileDirectory(with: urlString)
                    expect(path).toEventuallyNot(equal("img/onload/file.png"))
                }
            }
        }
    }
}
