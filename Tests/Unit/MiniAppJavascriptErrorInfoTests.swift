import Quick
import Nimble
@testable import MiniApp

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
            context("when getMiniAppErrorMessage is called with unknownError type") {
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
        }
    }
}
