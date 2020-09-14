import Quick
import Nimble
@testable import MiniApp

class MiniAppJavascriptErrorInfoTests: QuickSpec {

    override func spec() {
        describe("MiniApp Javascript Error info") {
            context("when getMiniAppErrorMessage is called with invalidCustomPermissionRequest type") {
                it("will return encoded json string") {
                    let miniAppCustomError = getMiniAppErrorMessage(MASDKCustomPermissionError.invalidCustomPermissionRequest)
                    expect(miniAppCustomError).toEventually(contain(MASDKCustomPermissionError.invalidCustomPermissionRequest.rawValue))
                    expect(miniAppCustomError).toEventually(contain(MASDKCustomPermissionError.invalidCustomPermissionRequest.description))
                }
            }
            context("when getMiniAppErrorMessage is called with invalidCustomPermissionsList type") {
                it("will return encoded json string") {
                    let miniAppCustomError = getMiniAppErrorMessage(MASDKCustomPermissionError.invalidCustomPermissionsList)
                    expect(miniAppCustomError).toEventually(contain(MASDKCustomPermissionError.invalidCustomPermissionsList.rawValue))
                    expect(miniAppCustomError).toEventually(contain(MASDKCustomPermissionError.invalidCustomPermissionsList.description))
                }
            }
            context("when getMiniAppErrorMessage is called with unknownError type") {
                it("will return encoded json string") {
                    let miniAppCustomError = getMiniAppErrorMessage(MiniAppErrorType.hostAppError)
                    expect(miniAppCustomError).toEventually(contain(MiniAppErrorType.hostAppError.rawValue))
                    expect(miniAppCustomError).toEventually(contain(MiniAppErrorType.hostAppError.description))
                }
            }
            context("when getMiniAppErrorMessage is called with unknownError type") {
                it("will return encoded json string") {
                    let miniAppCustomError = getMiniAppErrorMessage(MiniAppErrorType.unknownError)
                    expect(miniAppCustomError).toEventually(contain(MiniAppErrorType.unknownError.rawValue))
                    expect(miniAppCustomError).toEventually(contain(MiniAppErrorType.unknownError.description))
                }
            }
        }
    }
}
