import Quick
import Nimble
@testable import MiniApp

class UrlParserTests: QuickSpec {
    override func spec() {
        let env = Environment(bundle: MockBundle())
        describe("Url parser") {
            context("when getFileStoragePath is called with valid url") {
                it("will returns the path to store the file") {
                    let urlString = env.baseUrl?.appendingPathComponent("mini-abc/ver-abc/img/onload/file.png").absoluteString ?? ""
                    let path = UrlParser.getFileStoragePath(from: urlString, with: env)
                    expect(path).to(equal("img/onload/file.png"))
                }
            }

            context("when getFileStoragePath is called with invalid url") {
                it("will return nil") {
                    let urlString = env.baseUrl?.absoluteString ?? ""
                    let path = UrlParser.getFileStoragePath(from: urlString, with: env)
                    expect(path).to(beNil())
                }
            }
        }
    }
}
