import Quick
import Nimble
@testable import MiniApp

class UrlParserTests: QuickSpec {
    override func spec() {
        describe("Url parser") {
            context("when getFileStoragePath is called with valid url") {
                it("will returns the path to store the file") {
                    let urlString = "https://www.example.com/map-published-v2/mini-abc/ver-abc/img/onload/file.png"
                    let path = UrlParser.getFileStoragePath(from: urlString)
                    expect(path).toEventually(equal("img/onload/file.png"))
                }
            }
            context("when getFileStoragePath is called with valid url with no separator") {
                it("will return nil") {
                    let urlString = "https://www.example.com/mini-ver/rak0123/img/onload/file.png"
                    let path = UrlParser.getFileStoragePath(from: urlString)
                    expect(path).toEventually(beNil())
                }
            }
            context("when getFileStoragePath is called with invalid url") {
                it("will return nil") {
                    let urlString = "https://www.example.com/map-published-v2/"
                    let path = UrlParser.getFileStoragePath(from: urlString)
                    expect(path).toEventually(beNil())
                }
            }
        }
    }
}
