import Quick
import Nimble
@testable import MiniApp

// swiftlint:disable function_body_length
// swiftlint:disable cyclomatic_complexity
class MiniAppClientTests: QuickSpec {
    class MockSession: SessionProtocol {
        func startDownloadTask(downloadUrl: URL) {}

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
                let error = NSError.unknownServerError(httpResponse: urlResponse)
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

    func executeSession(data: [String: Any]? = nil, statusCode: Int = 200, error: NSError? = nil, completion: @escaping (Result<ResponseData, Error>) -> Void) {
        let mockSession = MockSession(data: data, statusCode: statusCode, error: error)
        let miniAppClient = MiniAppClient()
        miniAppClient.session = mockSession
        miniAppClient.getMiniAppsList(completionHandler: completion)
    }

    override func spec() {
        describe("start data task") {
            context("when network response contains valid data") {
                var testResult: Data?
                it("will pass a result to success completion handler with expected value") {
                    self.executeSession(data: ["key": "value"]) { (result) in
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
                    self.executeSession(statusCode: 400) { (result) in
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
                    self.executeSession(data: ["code": 404, "message": "error message"], statusCode: 404) { (result) in
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
                    self.executeSession(data: ["code": 404, "message": "error message description"], statusCode: 404) { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error as NSError
                        }
                    }

                    expect(testError?.localizedDescription).toEventually(equal("error message description"), timeout: 2)
                }

                let sessionDataForbidden = ["error": "Error", "error_description": "An error has occurred"]
                it("will pass an error to completion handler with expected message if it is a 401 error") {
                    self.executeSession(data: sessionDataForbidden, statusCode: 401) { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error as NSError
                        }
                    }
                    expect(testError?.localizedDescription).toEventually(equal("\(sessionDataForbidden["error"] ?? "null"): \(sessionDataForbidden["error_description"] ?? "null")"), timeout: 2)
                }
                it("will pass an error to completion handler with expected message if it is a 403 error") {
                    self.executeSession(data: sessionDataForbidden, statusCode: 403) { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error as NSError
                        }
                    }
                    expect(testError?.localizedDescription).toEventually(equal("\(sessionDataForbidden["error"] ?? "null"): \(sessionDataForbidden["error_description"] ?? "null")"), timeout: 2)
                }
            }
            context("when network response contains invalid error") {
                var testError: NSError?
                it("will pass an error to completion handler with expected code") {
                    self.executeSession(data: ["error_code": 404, "message": "error message"], statusCode: 404) { (result) in
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
        describe("fetch manifest information") {
            context("for a valid mini app") {
                var testResult: ResponseData?
                it("should return list of files of mini app") {
                    let mockSession = MockSession(data: ["id": "123",
                                                         "versionTag": "1.0",
                                                         "name": "Sample",
                                                         "files": ["http://www.example.com"]])
                    let miniAppClient = MiniAppClient()
                    miniAppClient.session = mockSession
                     miniAppClient.getAppManifest(appId: "abc", versionId: "ver") { (result) in
                        switch result {
                        case .success(let responseData):
                            testResult = responseData
                        case .failure:
                            break
                        }
                    }
                    expect(testResult).toEventuallyNot(beNil())
                }
                it("returns response data as nil") {
                    var testError: NSError = NSError.init(
                        domain: "Error",
                        code: 0,
                        userInfo: nil
                    )
                    let mockSession = MockSession(data: nil, statusCode: 400)
                    let miniAppClient = MiniAppClient()
                    miniAppClient.session = mockSession
                     miniAppClient.getAppManifest(appId: "abc", versionId: "ver") { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error as NSError
                        }
                    }
                    expect(testError.code).toEventually(equal(400), timeout: 2)
                }
                it("returns valid error response") {
                    var testError: NSError?
                    let mockSession = MockSession(data: ["code": 404, "message": "error message"], statusCode: 404)
                    let miniAppClient = MiniAppClient()
                    miniAppClient.session = mockSession
                     miniAppClient.getAppManifest(appId: "abc", versionId: "ver") { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error as NSError
                        }
                    }
                    expect(testError?.code).toEventually(equal(404), timeout: 2)
                }
                it("returns invalid error response") {
                    var testError: NSError?
                    let mockSession = MockSession(data: ["error_code": 404, "message": "error message"], statusCode: 404)
                    let miniAppClient = MiniAppClient()
                    miniAppClient.session = mockSession
                     miniAppClient.getAppManifest(appId: "abc", versionId: "ver") { (result) in
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
