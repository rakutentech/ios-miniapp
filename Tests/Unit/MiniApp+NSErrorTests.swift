import Quick
import Nimble
@testable import MiniApp

// swiftlint:disable function_body_length
class MiniAppNSErrorTests: QuickSpec {
    override func spec() {
        describe("When Mini app") {
            context("throws server error") {
                it("will return server with NSError type") {
                    let error = NSError.serverError(code: 0, message: "Server Error")
                    expect(error).toEventually(beAnInstanceOf(NSError.self), timeout: 2)
                }
                it("will return server error with code") {
                    let error = NSError.serverError(code: 11, message: "Server Error")
                    expect(error.code).toEventually(equal(11), timeout: 2)
                }
                it("will return server error with message") {
                    let error = NSError.serverError(code: 11, message: "Testing Server Error")
                    expect(error.localizedDescription).toEventually(equal("Testing Server Error"), timeout: 2)
                }
            }
            context("throws unknown error") {
                let urlResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 404, httpVersion: "1", headerFields: nil)
                let error = NSError.unknownServerError(httpResponse: urlResponse)
                it("will return server with NSError type") {
                    expect(error).toEventually(beAnInstanceOf(NSError.self), timeout: 2)
                }
                it("will return unknown error with code") {
                    expect(error.code).toEventually(equal(404), timeout: 2)
                }
                it("will return unknown error with message") {
                    expect(error.localizedDescription).toEventually(equal("Unknown server error occurred"), timeout: 2)
                }
                it("will return unknown error with code") {
                    let error = NSError.unknownServerError(httpResponse: nil)
                    expect(error.code).toEventually(equal(0), timeout: 2)
                }
            }
            context("throws invalid URL error") {
                let error = NSError.invalidURLError()
                it("will return server with NSError type") {
                    expect(error).toEventually(beAnInstanceOf(NSError.self), timeout: 2)
                }
                it("will return invalid URL error with code") {
                    expect(error.code).toEventually(equal(0), timeout: 2)
                }
                it("will return invalid URL error with message") {
                    expect(error.localizedDescription).toEventually(equal("Invalid URL error"), timeout: 2)
                }
            }
            context("throws invalid response received error") {
                let error = NSError.invalidResponseData()
                it("will return server with NSError type") {
                    expect(error).toEventually(beAnInstanceOf(NSError.self), timeout: 2)
                }
                it("will return invalid response received error with code") {
                    expect(error.code).toEventually(equal(0), timeout: 2)
                }
                it("will return invalid response received error with message") {
                    expect(error.localizedDescription).toEventually(equal("Invalid response received"), timeout: 2)
                }
            }
            context("throws downloading mini app failed error") {
                let error = NSError.downloadingFailed()
                it("will return server with NSError type") {
                    expect(error).toEventually(beAnInstanceOf(NSError.self), timeout: 2)
                }
                it("will return server error with code") {
                    expect(error.code).toEventually(equal(0), timeout: 2)
                }
                it("will return server error with message") {
                    expect(error.localizedDescription).toEventually(equal("Downloading failed"), timeout: 2)
                }
            }
        }
    }
}
