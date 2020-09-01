import Quick
import Nimble
@testable import MiniApp

class MiniAppJavascriptErrorInfoTests: QuickSpec {

    override func spec() {
        describe("MiniApp Javascript Error info") {
            context("when getMiniAppCustomPermissionError is called with invalidCustomPermissionRequest type") {
                it("will return encoded json string") {
                    let miniAppCustomError = getMiniAppCustomPermissionError(customPermissionError: .invalidCustomPermissionRequest)
                    guard let errorData: Data = miniAppCustomError.data(using: .utf8) else {
                        fail()
                        return
                    }
                    let decodedObj = try JSONDecoder().decode(MiniAppError.self, from: errorData)
                    expect(decodedObj.error.title).toEventually(equal(MiniAppCustomPermissionError.invalidCustomPermissionRequest))
                }
            }
            context("when getMiniAppCustomPermissionError is called with invalidCustomPermissionsList type") {
                it("will return encoded json string") {
                    let miniAppCustomError = getMiniAppCustomPermissionError(customPermissionError: .invalidCustomPermissionsList)
                    guard let errorData: Data = miniAppCustomError.data(using: .utf8) else {
                        fail()
                        return
                    }
                    let decodedObj = try JSONDecoder().decode(MiniAppError.self, from: errorData)
                    expect(decodedObj.error.title).toEventually(equal(MiniAppCustomPermissionError.invalidCustomPermissionsList))
                }
            }
            context("when getMiniAppCustomPermissionError is called with unknownError type") {
                it("will return encoded json string") {
                    let miniAppCustomError = getMiniAppCustomPermissionError(customPermissionError: .hostAppError)
                    guard let errorData: Data = miniAppCustomError.data(using: .utf8) else {
                        fail()
                        return
                    }
                    let decodedObj = try JSONDecoder().decode(MiniAppError.self, from: errorData)
                    expect(decodedObj.error.title).toEventually(equal(MiniAppCustomPermissionError.hostAppError))
                }
            }
            context("when getMiniAppCustomPermissionError is called with unknownError type") {
                it("will return encoded json string") {
                    let miniAppCustomError = getMiniAppCustomPermissionError(customPermissionError: .unknownError)
                    guard let errorData: Data = miniAppCustomError.data(using: .utf8) else {
                        fail()
                        return
                    }
                    let decodedObj = try JSONDecoder().decode(MiniAppError.self, from: errorData)
                    expect(decodedObj.error.title).toEventually(equal(MiniAppCustomPermissionError.unknownError))
                }
            }
        }
    }
}
