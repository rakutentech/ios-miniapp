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
                    expect(error).toEventually(beAnInstanceOf(NSError.self), timeout: .seconds(2))
                }
                it("will return server error with code") {
                    let error = NSError.serverError(code: 11, message: "Server Error")
                    expect(error.code).toEventually(equal(11), timeout: .seconds(2))
                }
                it("will return server error with message") {
                    let error = NSError.serverError(code: 11, message: "Testing Server Error")
                    expect(error.localizedDescription).toEventually(equal("Testing Server Error"), timeout: .seconds(2))
                }
            }
            context("throws unknown error") {
                let urlResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 400, httpVersion: "1", headerFields: nil)
                let error = NSError.unknownServerError(httpResponse: urlResponse)
                it("will return server with NSError type") {
                    expect(error).toEventually(beAnInstanceOf(NSError.self), timeout: .seconds(2))
                }
                it("will return unknown error with code") {
                    expect(error.code).toEventually(equal(400), timeout: .seconds(2))
                }
                it("will return unknown error with message") {
                    expect(error.localizedDescription).toEventually(equal("Unknown server error occurred"), timeout: .seconds(2))
                }
                it("will return unknown error with code") {
                    let error = NSError.unknownServerError(httpResponse: nil)
                    expect(error.code).toEventually(equal(0), timeout: .seconds(2))
                }
            }
            context("throws invalid URL error") {
                let error = NSError.invalidURLError()
                it("will return server with NSError type") {
                    expect(error).toEventually(beAnInstanceOf(NSError.self), timeout: .seconds(2))
                }
                it("will return invalid URL error with code") {
                    expect(error.code).toEventually(equal(MiniAppSDKErrorCode.invalidURLError.rawValue), timeout: .seconds(2))
                }
            }
            context("throws invalid response received error") {
                let error = NSError.invalidResponseData()
                it("will return server with NSError type") {
                    expect(error).toEventually(beAnInstanceOf(NSError.self), timeout: .seconds(2))
                }
                it("will return invalid response received error with code") {
                    expect(error.code).toEventually(equal(MiniAppSDKErrorCode.invalidResponseData.rawValue), timeout: .seconds(2))
                }
            }
            context("throws downloading mini app failed error") {
                let error = NSError.downloadingFailed()
                it("will return server with NSError type") {
                    expect(error).toEventually(beAnInstanceOf(NSError.self), timeout: .seconds(2))
                }
                it("will return server error with code") {
                    expect(error.code).toEventually(equal(MiniAppSDKErrorCode.downloadingFailed.rawValue), timeout: .seconds(2))
                }
            }
        }
    }
}
