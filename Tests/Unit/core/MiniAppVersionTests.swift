import Quick
import Nimble
@testable import MiniApp

// swiftlint:disable function_body_length
class MiniAppVersionTests: QuickSpec {

    override func spec() {
        describe("Mini app version tests") {
            context("when mini app version is passed with empty string") {
                it("will return major, minor, hotfix, environment values as nil") {
                    let miniAppVersion = MiniAppVersion(string: "")
                    expect(miniAppVersion?.major).to(beNil())
                    expect(miniAppVersion?.minor).to(beNil())
                    expect(miniAppVersion?.hotfix).to(beNil())
                    expect(miniAppVersion?.environment).to(beNil())
                }
            }
            context("when mini app version is passed with nil") {
                it("will return nil") {
                    let miniAppVersion = MiniAppVersion(string: nil)
                    expect(miniAppVersion).to(beNil())
                }
            }
            context("when mini app version is passed with only major version") {
                it("will return only major version and other values as nil") {
                    let miniAppVersion = MiniAppVersion(string: "3")
                    expect(miniAppVersion?.major).toEventually(equal(3))
                    expect(miniAppVersion?.minor).to(beNil())
                    expect(miniAppVersion?.hotfix).to(beNil())
                    expect(miniAppVersion?.environment).to(beNil())
                }
            }
            context("when mini app version is passed with only major & minor version") {
                it("will return only major, minor version and other values as nil") {
                    let miniAppVersion = MiniAppVersion(string: "3.8")
                    expect(miniAppVersion?.major).toEventually(equal(3))
                    expect(miniAppVersion?.minor).toEventually(equal(8))
                    expect(miniAppVersion?.hotfix).to(beNil())
                    expect(miniAppVersion?.environment).to(beNil())
                }
            }
            context("when mini app version is passed with only major, minor & hotfix version") {
                it("will return only major, minor, hotfix versions and other values as nil") {
                    let miniAppVersion = MiniAppVersion(string: "3.8.0")
                    expect(miniAppVersion?.major).toEventually(equal(3))
                    expect(miniAppVersion?.minor).toEventually(equal(8))
                    expect(miniAppVersion?.hotfix).toEventually(equal(0))
                    expect(miniAppVersion?.environment).to(beNil())
                }
            }
            context("when mini app version is passed with valid version") {
                it("will return only major, minor versions and other values as nil") {
                    let miniAppVersion = MiniAppVersion(string: "3.8.0- Dev")
                    expect(miniAppVersion?.major).toEventually(equal(3))
                    expect(miniAppVersion?.minor).toEventually(equal(8))
                    expect(miniAppVersion?.hotfix).toEventually(equal(0))
                    expect(miniAppVersion?.environment).toEventually(equal("- Dev"))
                }
            }
            context("when mini app version is passed with only major, minor version") {
                it("will return only major, minor and other values as nil") {
                    let miniAppVersion = MiniAppVersion(string: "3.8.-")
                    expect(miniAppVersion?.major).toEventually(equal(3))
                    expect(miniAppVersion?.minor).toEventually(equal(8))
                    expect(miniAppVersion?.hotfix).to(beNil())
                    expect(miniAppVersion?.environment).toEventually(equal("-"))
                }
            }
        }
    }
}
