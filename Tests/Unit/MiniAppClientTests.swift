import Quick
import Nimble
@testable import MiniApp

// swiftlint:disable function_body_length
// swiftlint:disable cyclomatic_complexity
class MiniAppClientTests: QuickSpec {
    class MockSession: SessionProtocol {
        func startDownloadTask(downloadUrl: URL) { }

        var data: Data?
        var error: Error?
        var attempts = 0
        var urlResponse: HTTPURLResponse?
        var jsonObject: [String: Any]?
        var serverErrorCode = Int()

        func startDataTask(with request: URLRequest, completionHandler: @escaping (Result<ResponseData, Error>) -> Void) {
            attempts += 1
            urlResponse = HTTPURLResponse(url: URL(string: mockHost)!, statusCode: serverErrorCode, httpVersion: "1", headerFields: nil)
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

    @discardableResult func executeSession(data: [String: Any]? = nil, statusCode: Int = 200, error: NSError? = nil, completion: @escaping (Result<ResponseData, Error>) -> Void) -> MiniAppClient {
        let mockSession = MockSession(data: data, statusCode: statusCode, error: error)
        let miniAppClient = MiniAppClient()
        miniAppClient.session = mockSession
        miniAppClient.getMiniAppsList(completionHandler: completion)
        return miniAppClient
    }

    func executeSessionWithBadEnvironment(data: [String: Any]? = nil, statusCode: Int = 200, error: NSError? = nil, completion: @escaping (Result<ResponseData, Error>) -> Void) {
        let mockSession = MockSession(data: data, statusCode: statusCode, error: error)
        let mockBundle = MockBundle()
        mockBundle.mockAppVersion = "1.0"
        let environment = Environment(bundle: mockBundle)
        let miniAppClient = MiniAppClient()
        miniAppClient.environment = environment
        miniAppClient.session = mockSession
        miniAppClient.getMiniAppsList(completionHandler: completion)
    }

    override func spec() {
        describe("start data task") {
            context("when network response contains valid data") {
                var testResult: Data?
                it("will pass a result to success completion handler with expected value") {
                    let client = self.executeSession(data: ["key": "value"]) { (result) in
                        switch result {
                        case .success(let responseData):
                            testResult = responseData.data
                        case .failure:
                            break
                        }
                    }
                    expect(testResult).toEventuallyNot(beNil())
                    expect((client.session as? MockSession)?.attempts).toNotEventually(beGreaterThan(1), timeout: .seconds(2))
                }
            }

            context("when network response doesn't contain data") {
                var testError: NSError = NSError.init(
                    domain: "Error",
                    code: 0,
                    userInfo: nil
                )
                it("will pass an error with status code and completion handler expected to return the same") {
                    let client = self.executeSession(statusCode: 400) { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error as NSError
                        }
                    }
                    expect(testError.code).toEventually(equal(400), timeout: .seconds(2))
                    expect((client.session as? MockSession)?.attempts).toNotEventually(beGreaterThan(1), timeout: .seconds(2))
                }
            }

            context("when network response contains valid error json") {
                var testError: NSError?
                it("will pass an error to completion handler with expected code") {
                    let client = self.executeSession(data: ["code": 400, "message": "error message"], statusCode: 400) { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error as NSError
                        }
                    }
                    expect(testError?.code).toEventually(equal(400), timeout: .seconds(2))
                    expect((client.session as? MockSession)?.attempts).toNotEventually(beGreaterThan(1), timeout: .seconds(2))
                }
                it("will pass an error to completion handler with expected message") {
                    let client = self.executeSession(data: ["code": 400, "message": "error message description"], statusCode: 400) { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error as NSError
                        }
                    }

                    expect(testError?.localizedDescription).toEventually(equal("error message description"), timeout: .seconds(2))
                    expect((client.session as? MockSession)?.attempts).toNotEventually(beGreaterThan(1), timeout: .seconds(2))
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
                    expect(testError?.localizedDescription)
                        .toEventually(
                            equal("\(sessionDataForbidden["error"] ?? "null"): \(sessionDataForbidden["error_description"] ?? "null")"),
                            timeout: .seconds(2))
                }
                it("will pass an error to completion handler with expected message if it is a 403 error") {
                    let client = self.executeSession(data: sessionDataForbidden, statusCode: 403) { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error as NSError
                        }
                    }
                    expect(testError?.localizedDescription)
                        .toEventually(
                            equal("\(sessionDataForbidden["error"] ?? "null"): \(sessionDataForbidden["error_description"] ?? "null")"),
                            timeout: .seconds(2))
                    expect((client.session as? MockSession)?.attempts).toNotEventually(beGreaterThan(1), timeout: .seconds(2))
                }
            }
            context("when network response contains invalid error") {
                var testError: NSError?
                it("will pass an error to completion handler with expected code") {
                    let client = self.executeSession(data: ["error_code": 404, "message": "error message"], statusCode: 404) { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error as NSError
                        }
                    }
                    expect(testError).toEventually(beAnInstanceOf(NSError.self), timeout: .seconds(2))
                    expect((client.session as? MockSession)?.attempts).toNotEventually(beGreaterThan(1), timeout: .seconds(2))
                }
            }
            context("when environment is invalid") {
                var testError: NSError?
                it("will pass an error to completion handler with expected code") {
                    let client = self.executeSession(data: ["error_code": 404, "message": "error message"], statusCode: 404) { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error as NSError
                        }
                    }
                    expect(testError).toEventually(beAnInstanceOf(NSError.self), timeout: .seconds(2))
                    expect((client.session as? MockSession)?.attempts).toNotEventually(beGreaterThan(1), timeout: .seconds(2))
                }
            }
            context("when environment is failing") {
                var testError: NSError?
                var client: MiniAppClient?
                it("will pass an error after 5 tries to completion handler with expected code") {
                    let startTime = Date()
                    var timeSpent = 0.0
                    client = self.executeSession(data: ["error_code": 500, "message": "error message"], statusCode: 500) { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error as NSError
                            timeSpent = abs(startTime.timeIntervalSinceNow)
                        }
                    }
                    expect(testError).toEventually(beAnInstanceOf(NSError.self), timeout: .seconds(20))
                    expect((client?.session as? MockSession)?.attempts).toEventually(equal(6), timeout: .seconds(20)) // 1 attempt + 5 retries
                    expect(timeSpent).toEventually(beGreaterThan(15.0), timeout: .seconds(20))
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
                        "files": ["\(mockHost)"]])
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
                    expect(testError.code).toEventually(equal(400), timeout: .seconds(2))
                }
                it("returns valid error response") {
                    var testError: NSError?
                    let mockSession = MockSession(data: ["code": 400, "message": "error message"], statusCode: 400)
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
                    expect(testError?.code).toEventually(equal(400), timeout: .seconds(2))
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
                    expect(testError).toEventually(beAnInstanceOf(NSError.self), timeout: .seconds(2))
                }
            }
        }
        describe("override configuration at runtime") {
            let projectId = "RASProjectId"
            let versionKey = "CFBundleShortVersionString"
            let subscriptionKey = "RASProjectSubscriptionKey"
            let endpointKey = "RMAAPIEndpoint"
            let isPreviewMode = "RMAIsPreviewMode"
            let bundle = Bundle.main as EnvironmentProtocol
            let testURL = mockHost
            let testID = "testID"
            let testProjectID = "testProjectID"
            let testKey = "testKey"
            let testVersion = "testVersion"

            context("when no configuration is provided") {
                it("it uses plist configuration as environment") {
                    let miniAppClient = MiniAppClient()

                    expect(miniAppClient.environment.projectId).to(equal(bundle.value(for: projectId)))
                    expect(miniAppClient.environment.appVersion).to(equal(bundle.value(for: versionKey)))
                    expect(miniAppClient.environment.subscriptionKey).to(equal(bundle.value(for: subscriptionKey)))
                    expect(miniAppClient.environment.baseUrl?.absoluteString).to(equal(bundle.value(for: endpointKey)))
                    expect(miniAppClient.environment.isPreviewMode).notTo(equal(bundle.bool(for: isPreviewMode)))
                }
            }

            context("when a configuration is provided") {
                it("it uses configuration values as environment") {
                    let miniAppClient = MiniAppClient(with: MiniAppSdkConfig(
                        baseUrl: testURL,
                        rasProjectId: testProjectID,
                        subscriptionKey: testKey,
                        hostAppVersion: testVersion,
                        isPreviewMode: true))

                    expect(miniAppClient.environment.projectId).to(equal(testProjectID))
                    expect(miniAppClient.environment.appVersion).to(equal(testVersion))
                    expect(miniAppClient.environment.subscriptionKey).to(equal(testKey))
                    expect(miniAppClient.environment.baseUrl?.absoluteString).to(equal(testURL))
                    expect(miniAppClient.environment.isPreviewMode).to(be(true))
                }
            }

            context("when a configuration is updated") {
                it("it uses configuration values as environment") {
                    let miniAppClient = MiniAppClient(with: MiniAppSdkConfig(
                        baseUrl: testURL,
                        rasProjectId: testProjectID,
                        subscriptionKey: testKey,
                        hostAppVersion: testVersion,
                        isPreviewMode: true))

                    miniAppClient.updateEnvironment(with: MiniAppSdkConfig(
                        baseUrl: mockHost,
                        rasProjectId: "id2",
                        subscriptionKey: "key2",
                        hostAppVersion: "newversion",
                        isPreviewMode: false))

                    expect(miniAppClient.environment.projectId).to(equal("id2"))
                    expect(miniAppClient.environment.appVersion).to(equal("newversion"))
                    expect(miniAppClient.environment.subscriptionKey).to(equal("key2"))
                    expect(miniAppClient.environment.baseUrl?.absoluteString).to(equal(mockHost))
                    expect(miniAppClient.environment.isPreviewMode).to(be(false))
                }
            }

            context("when a custom parameter is provided") {
                it("it uses provided custom parameters values as environment") {
                    let miniAppClient = MiniAppClient(baseUrl: testURL, rasProjectId: testProjectID)

                    expect(miniAppClient.environment.projectId).to(equal(testProjectID))
                    expect(miniAppClient.environment.appVersion).to(equal(bundle.value(for: versionKey)))
                    expect(miniAppClient.environment.subscriptionKey).to(equal(bundle.value(for: subscriptionKey)))
                    expect(miniAppClient.environment.baseUrl?.absoluteString).to(equal(testURL))
                }
            }

            context("when we update configuration after creating client") {
                it("it uses configuration values as environment") {
                    let miniAppClient = MiniAppClient()
                    miniAppClient.updateEnvironment(with: MiniAppSdkConfig(baseUrl: testURL,
                        rasProjectId: testProjectID,
                        subscriptionKey: testKey,
                        hostAppVersion: testVersion,
                        isPreviewMode: true))

                    expect(miniAppClient.environment.projectId).to(equal(testProjectID))
                    expect(miniAppClient.environment.appVersion).to(equal(testVersion))
                    expect(miniAppClient.environment.subscriptionKey).to(equal(testKey))
                    expect(miniAppClient.environment.baseUrl?.absoluteString).to(equal(testURL))
                    expect(miniAppClient.environment.isPreviewMode).to(be(true))
                }
            }

            context("when we provide nil configuration") {
                it("it uses plist configuration as environment") {
                    let miniAppClient = MiniAppClient(baseUrl: testURL, rasProjectId: testID)
                    miniAppClient.updateEnvironment(with: nil)

                    expect(miniAppClient.environment.projectId).to(equal(bundle.value(for: projectId)))
                    expect(miniAppClient.environment.appVersion).to(equal(bundle.value(for: versionKey)))
                    expect(miniAppClient.environment.subscriptionKey).to(equal(bundle.value(for: subscriptionKey)))
                    expect(miniAppClient.environment.baseUrl?.absoluteString).to(equal(bundle.value(for: endpointKey)))
                    expect(miniAppClient.environment.isPreviewMode).to(equal(bundle.bool(for: isPreviewMode)))
                }
            }
        }
    }
}
