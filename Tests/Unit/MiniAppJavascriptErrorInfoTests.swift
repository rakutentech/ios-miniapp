import Quick
import Nimble
@testable import MiniApp

class MiniAppJavascriptErrorInfoTests: QuickSpec {

    override func spec() {
        describe("MiniApp Javascript Error info") {
            context("when getMiniAppErrorMessage is called with invalidCustomPermissionRequest type") {
                it("will return encoded json string") {
                    let miniAppCustomError = getMiniAppErrorMessage(MASDKCustomPermissionError.invalidCustomPermissionRequest)
                    guard let errorData: Data = miniAppCustomError.data(using: .utf8) else {
                        fail()
                        return
                    }
                    let decodedObj = try JSONDecoder().decode(MiniAppErrorDetail.self, from: errorData)
                    expect(MASDKCustomPermissionError(rawValue: decodedObj.name)).toEventually(equal(MASDKCustomPermissionError.invalidCustomPermissionRequest))
                }
            }
            context("when getMiniAppErrorMessage is called with invalidCustomPermissionsList type") {
                it("will return encoded json string") {
                    let miniAppCustomError = getMiniAppErrorMessage(MASDKCustomPermissionError.invalidCustomPermissionsList)
                    guard let errorData: Data = miniAppCustomError.data(using: .utf8) else {
                        fail()
                        return
                    }
                    let decodedObj = try JSONDecoder().decode(MiniAppErrorDetail.self, from: errorData)
                    expect(MASDKCustomPermissionError(rawValue: decodedObj.name)).toEventually(equal(MASDKCustomPermissionError.invalidCustomPermissionsList))
                }
            }
            context("when getMiniAppErrorMessage is called with unknownError type") {
                it("will return encoded json string") {
                    let miniAppCustomError = getMiniAppErrorMessage(MiniAppErrorType.hostAppError)
                    guard let errorData: Data = miniAppCustomError.data(using: .utf8) else {
                        fail()
                        return
                    }
                    let decodedObj = try JSONDecoder().decode(MiniAppErrorDetail.self, from: errorData)
                    expect(MiniAppErrorType(rawValue: decodedObj.name)).toEventually(equal(MiniAppErrorType.hostAppError))
                }
            }
            context("when getMiniAppErrorMessage is called with unknownError type") {
                it("will return encoded json string") {
                    let miniAppCustomError = getMiniAppErrorMessage(MiniAppErrorType.unknownError)
                    guard let errorData: Data = miniAppCustomError.data(using: .utf8) else {
                        fail()
                        return
                    }
                    let decodedObj = try JSONDecoder().decode(MiniAppErrorDetail.self, from: errorData)
                    expect(MiniAppErrorType(rawValue: decodedObj.name)).toEventually(equal(MiniAppErrorType.unknownError))
                }
            }
        }
    }
}
