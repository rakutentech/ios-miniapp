import Quick
import Nimble
@testable import MiniApp

// swiftlint:disable function_body_length
class MiniAppClientTests: QuickSpec {

    override func spec() {
        describe("start data task") {
            class MockSession: SessionProtocol {
                var data: Data?
                var error: Error?
                var urlResponse: HTTPURLResponse?
                var jsonObject: [String: Any]?
                var serverErrorCode = Int()

                func startDataTask(with request: URLRequest, completionHandler: @escaping (Result<ResponseData, Error>) -> Void) {
                        urlResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: serverErrorCode, httpVersion: "1", headerFields: nil)
                        if let json = jsonObject {
                            data = try? JSONSerialization.data(withJSONObject: json, options: [])
                        }
                        if let error = error {
                            return completionHandler(.failure(error))
                        }
                        guard let httpResponse = urlResponse, let data = data else {
                            let error = NSError(
                                domain: "APIClient",
                                code: (urlResponse)?.statusCode ?? 0,
                                userInfo: [NSLocalizedDescriptionKey: "Unknown server error occurred"]
                            )
                            return completionHandler(.failure(error))
                        }
                        return completionHandler(.success(ResponseData(data, httpResponse)))
                }

                init(data: [String: Any]? = nil, statusCode: Int = 200, error: NSError? = nil) {
                    self.jsonObject = data
                    self.serverErrorCode = statusCode
                    self.error = error
                }
            }
            context("when network response contains valid data") {
                var testResult: Data?
                it("will pass a result to success completion handler with expected value") {
                    let mockSession = MockSession(data: ["key": "value"])
                    MiniAppClient(session: mockSession).getMiniAppsList { (result) in
                        switch result {
                        case .success(let responseData):
                            testResult = responseData.data
                        case .failure:
                            break
                        }
                    }
                    expect(testResult).toEventuallyNot(beNil())
                }
            }

            context("when network response doesn't contain data") {
                var testError: NSError = NSError.init(
                    domain: "Error",
                    code: 0,
                    userInfo: nil
                )
                it("will pass an error with status code and completion handler expected to return the same") {
                    let mockSession = MockSession(data: nil, statusCode: 400)
                    MiniAppClient(session: mockSession).getMiniAppsList { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error as NSError
                        }
                    }
                    expect(testError.code).toEventually(equal(400), timeout: 2)
                }
            }

            context("when network response contains valid error json") {
                var testError: NSError?
                it("will pass an error to completion handler with expected code") {
                    let mockSession = MockSession(data: ["code": 404, "message": "error message"], statusCode: 404)
                    MiniAppClient(session: mockSession).getMiniAppsList { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error as NSError
                        }
                    }
                    expect(testError?.code).toEventually(equal(404), timeout: 2)
                }
                it("will pass an error to completion handler with expected message") {
                    let mockSession = MockSession(data: ["code": 404, "message": "error message description"], statusCode: 404)
                    MiniAppClient(session: mockSession).getMiniAppsList { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error as NSError
                        }
                    }

                    expect(testError?.localizedDescription).toEventually(equal("error message description"), timeout: 2)
                }
            }
            context("when network response contains invalid error") {
                var testError: NSError?
                it("will pass an error to completion handler with expected code") {
                    let mockSession = MockSession(data: ["error_code": 404, "message": "error message"], statusCode: 404)
                    MiniAppClient(session: mockSession).getMiniAppsList { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error as NSError
                        }
                    }
                    expect(testError).toEventually(beAnInstanceOf(NSError.self), timeout: 2)
                }
            }
        }
    }
}
