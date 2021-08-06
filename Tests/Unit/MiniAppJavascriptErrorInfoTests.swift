import Quick
import Nimble
@testable import MiniApp

// swiftlint:disable function_body_length
class MiniAppJavascriptErrorInfoTests: QuickSpec {

    override func spec() {
        describe("MiniApp Javascript Error info") {
            context("when getMiniAppErrorMessage is called with invalidCustomPermissionRequest type") {
                it("will return encoded json string") {
                    let miniAppCustomError = getMiniAppErrorMessage(MASDKCustomPermissionError.invalidCustomPermissionRequest)
                    expect(miniAppCustomError).to(contain(MASDKCustomPermissionError.invalidCustomPermissionRequest.rawValue))
                    expect(miniAppCustomError).to(contain(MASDKCustomPermissionError.invalidCustomPermissionRequest.description))
                }
            }
            context("when getMiniAppErrorMessage is called with invalidCustomPermissionsList type") {
                it("will return encoded json string") {
                    let miniAppCustomError = getMiniAppErrorMessage(MASDKCustomPermissionError.invalidCustomPermissionsList)
                    expect(miniAppCustomError).to(contain(MASDKCustomPermissionError.invalidCustomPermissionsList.rawValue))
                    expect(miniAppCustomError).to(contain(MASDKCustomPermissionError.invalidCustomPermissionsList.description))
                }
            }
            context("when getMiniAppErrorMessage is called with hostAppError type") {
                it("will return encoded json string") {
                    let miniAppCustomError = getMiniAppErrorMessage(MiniAppErrorType.hostAppError)
                    expect(miniAppCustomError).to(contain(MiniAppErrorType.hostAppError.rawValue))
                    expect(miniAppCustomError).to(contain(MiniAppErrorType.hostAppError.description))
                }
            }
            context("when getMiniAppErrorMessage is called with unknownError type") {
                it("will return encoded json string") {
                    let miniAppCustomError = getMiniAppErrorMessage(MiniAppErrorType.unknownError)
                    expect(miniAppCustomError).to(contain(MiniAppErrorType.unknownError.rawValue))
                    expect(miniAppCustomError).to(contain(MiniAppErrorType.unknownError.description))
                }
            }
            context("when getMiniAppErrorMessage is called with MiniAppJavaScriptError internalError type") {
                it("will return rawValue and description of the error") {
                    let miniAppCustomError = getMiniAppErrorMessage(MiniAppJavaScriptError.internalError)
                    expect(miniAppCustomError).to(contain(MiniAppJavaScriptError.internalError.rawValue))
                    expect(miniAppCustomError.description).to(contain(MiniAppJavaScriptError.internalError.description))
                }
            }
            context("when getMiniAppErrorMessage is called with MiniAppJavaScriptError valueIsEmpty type") {
                it("will return rawValue and description of the error") {
                    let miniAppCustomError = getMiniAppErrorMessage(MiniAppJavaScriptError.valueIsEmpty)
                    expect(miniAppCustomError).to(contain(MiniAppJavaScriptError.valueIsEmpty.rawValue))
                    expect(miniAppCustomError.description).to(contain(MiniAppJavaScriptError.valueIsEmpty.description))
                }
            }
            context("when getMiniAppErrorMessage is called with MiniAppJavaScriptError scopeError type") {
                it("will return rawValue and description of the error") {
                    let miniAppCustomError = getMiniAppErrorMessage(MiniAppJavaScriptError.scopeError)
                    expect(miniAppCustomError).to(contain(MiniAppJavaScriptError.scopeError.rawValue))
                    expect(miniAppCustomError.description).to(contain(MiniAppJavaScriptError.scopeError.description))
                }
            }
            context("when getMiniAppErrorMessage is called with MiniAppJavaScriptError audienceError type") {
                it("will return rawValue and description of the error") {
                    let miniAppCustomError = getMiniAppErrorMessage(MiniAppJavaScriptError.audienceError)
                    expect(miniAppCustomError).to(contain(MiniAppJavaScriptError.audienceError.rawValue))
                    expect(miniAppCustomError.description).to(contain(MiniAppJavaScriptError.audienceError.description))
                }
            }
        }
    }
}
