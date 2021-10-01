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
                    expect(error).to(beAnInstanceOf(NSError.self))
                }
                it("will return server error with code") {
                    let error = NSError.serverError(code: 11, message: "Server Error")
                    expect(error.code).to(equal(11))
                }
                it("will return server error with message") {
                    let error = NSError.serverError(code: 11, message: "Testing Server Error")
                    expect(error.localizedDescription).to(equal("Testing Server Error"))
                }
            }
            context("throws unknown error") {
                let urlResponse = HTTPURLResponse(url: URL(string: mockHost)!, statusCode: 400, httpVersion: "1", headerFields: nil)
                let error = NSError.unknownServerError(httpResponse: urlResponse)
                it("will return server with NSError type") {
                    expect(error).to(beAnInstanceOf(NSError.self))
                }
                it("will return unknown error with code") {
                    expect(error.code).to(equal(400))
                }
                it("will return unknown error with message") {
                    expect(error.localizedDescription).to(equal("Unknown server error occurred"))
                }
                it("will return unknown error with code") {
                    let error = NSError.unknownServerError(httpResponse: nil)
                    expect(error.code).to(equal(0))
                }
            }
            context("throws invalid URL error") {
                let error = NSError.invalidURLError()
                it("will return server with NSError type") {
                    expect(error).to(beAnInstanceOf(NSError.self))
                }
                it("will return invalid URL error with code") {
                    expect(error.code).to(equal(MiniAppSDKErrorCode.invalidURLError.rawValue))
                }
            }
            context("throws invalid response received error") {
                let error = NSError.invalidResponseData()
                it("will return server with NSError type") {
                    expect(error).to(beAnInstanceOf(NSError.self))
                }
                it("will return invalid response received error with code") {
                    expect(error.code).to(equal(MiniAppSDKErrorCode.invalidResponseData.rawValue))
                }
            }
            context("throws downloading mini app failed error") {
                let error = NSError.downloadingFailed()
                it("will return server with NSError type") {
                    expect(error).to(beAnInstanceOf(NSError.self))
                }
                it("will return server error with code") {
                    expect(error.code).to(equal(MiniAppSDKErrorCode.downloadingFailed.rawValue))
                }
            }
        }
    }
}
