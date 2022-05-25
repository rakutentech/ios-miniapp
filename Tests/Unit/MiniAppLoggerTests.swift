import Quick
import Nimble
import Foundation
@testable import MiniApp

class MiniAppLoggerTests: QuickSpec {
    override func spec() {
        let error = NSError.serverError(code: 11, message: "Server Error")
        describe("MiniAppLogger test") {
            context("when I log something on debug") {
                it("will not crash") {
                    expect {
                        MiniAppLogger.d("test")
                    }.toNot(throwAssertion())
                }
            }
            context("when I log something on verbose") {
                it("will not crash") {
                    expect {
                        MiniAppLogger.v("test")
                    }.toNot(throwAssertion())
                }
            }
            context("when I log something on warning") {
                it("will not crash") {
                    expect {
                        MiniAppLogger.w("test")
                    }.toNot(throwAssertion())
                }
            }
            context("when I log something on error with no error") {
                it("will not crash") {
                    expect {
                        MiniAppLogger.e("test")
                    }.toNot(throwAssertion())
                }
            }
            context("when I log something on error with an error object") {
                it("will not crash") {
                    expect {
                        MiniAppLogger.e("test", error)
                    }.toNot(throwAssertion())
                }
            }
        }
    }
}
