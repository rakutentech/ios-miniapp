import Quick
import Nimble
@testable import MiniApp

// swiftlint:disable function_body_length
class APIClientSpec: QuickSpec {
    #if RMA_SDK_SIGNATURE

    override func spec() {

        describe("send function") {
            class SessionMock: SessionType {
                var jsonObj: KeyModel?
                var jsonError: [String: Any]?
                var serverErrorCode: Int?
                var error: NSError?

                func startTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
                    let response = HTTPURLResponse(url: URL(string: "https://test.com")!, statusCode: serverErrorCode ?? 0, httpVersion: "1", headerFields: nil)
                    var data: Data?
                    if let json = jsonObj {
                        data = try? JSONEncoder().encode(json)
                    } else if let json = jsonError {
                        data = try? JSONSerialization.data(withJSONObject: json, options: [])
                    }
                    completionHandler(data, response, error)
                }

                init(json: KeyModel? = nil, jsonError: [String: Any]? = nil, statusCode: Int = 200, error: NSError? = nil) {
                    self.jsonObj = json
                    self.jsonError = jsonError
                    self.serverErrorCode = statusCode
                    self.error = error
                }
            }
            context("when network response contains valid result json") {
                var testResult: KeyModel?
                let keyModel = KeyModel(identifier: "foo", key: "bar", pem: "baz")

                it("will pass a result to completion handler with expected value") {
                    let sessionMock = SessionMock(json: keyModel)
                    SignatureAPI(session: sessionMock).send(
                        request: URLRequest(url: URL(string: "https://test.com")!),
                        completionHandler: {(result) in
                            switch result {
                            case .success(let response):
                                testResult = response
                            case .failure:
                                break
                            }
                        })
                    expect(testResult).toEventually(equal(keyModel), timeout: .seconds(2))
                }
            }
            context("when network response contains valid error json") {
                var testError: NSError = NSError.init(domain: "Test", code: 0, userInfo: nil)

                it("will pass an error to completion handler with expected code") {
                    let sessionMock = SessionMock(jsonError: ["code": 1, "message": "error message"])
                    SignatureAPI(session: sessionMock).send(
                        request: URLRequest(url: URL(string: "https://test.com")!),
                        completionHandler: { (result) in
                            switch result {
                            case .success:
                                break
                            case .failure(let error):
                                testError = error as NSError
                            }
                        })

                    expect(testError.code).toEventually(equal(1), timeout: .seconds(2))
                }

                it("will pass an error to completion handler with expected message") {
                    let sessionMock = SessionMock(jsonError: ["code": 1, "message": "error message"])
                    SignatureAPI(session: sessionMock).send(
                        request: URLRequest(url: URL(string: "https://test.com")!),
                        completionHandler: { (result) in
                            switch result {
                            case .success:
                                break
                            case .failure(let error):
                                testError = error as NSError
                            }
                        })

                    expect(testError.localizedDescription).toEventually(equal("error message"), timeout: .seconds(2))
                }
            }
            context("when network response contains json that doesn't match our models") {
                let keyModel = KeyModel(identifier: "foo", key: "bar", pem: "baz")

                it("will pass a non-nil error to completion handler") {
                    var testError: NSError = NSError.init(domain: "Test", code: 0, userInfo: nil)
                    let sessionMock = SessionMock(json: keyModel)
                    SignatureAPI(session: sessionMock).send(
                        request: URLRequest(url: URL(string: "https://test.com")!),
                        completionHandler: { (result) in
                            switch result {
                            case .success:
                                break
                            case .failure(let error):
                                testError = error as NSError
                            }
                        })

                    expect(testError).toEventually(beAnInstanceOf(NSError.self), timeout: .seconds(2))
                }
            }
            context("when network response doesn't contain json data") {
                var testError: NSError = NSError.init(domain: "Test", code: 0, userInfo: nil)

                it("will pass an error with code set to server status code to completion handler and error is nil") {
                    let sessionMock = SessionMock(json: nil, statusCode: 400)
                    SignatureAPI(session: sessionMock).send(
                        request: URLRequest(url: URL(string: "https://test.com")!),
                        completionHandler: { (result) in
                            switch result {
                            case .success:
                                break
                            case .failure(let error):
                                testError = error as NSError
                            }
                        })

                    expect(testError.code).toEventually(equal(400), timeout: .seconds(2))
                }

                it("will pass any system error to completion handler even when response received") {
                    let sessionMock = SessionMock(json: nil, error: NSError(domain: "Test", code: 123, userInfo: nil))
                    SignatureAPI(session: sessionMock).send(
                        request: URLRequest(url: URL(string: "https://test.com")!),
                        completionHandler: { (result) in
                            switch result {
                            case .success:
                                break
                            case .failure(let error):
                                testError = error as NSError
                            }
                        })

                    expect(testError).toEventually(equal(sessionMock.error), timeout: .seconds(2))
                }
            }
        }
    }
    #endif
}
