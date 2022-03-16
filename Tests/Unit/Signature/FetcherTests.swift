import Quick
import Nimble
@testable import MiniApp

// swiftlint:disable function_body_length
class FetcherSpec: QuickSpec {
    #if RMA_SDK_SIGNATURE
    override func spec() {
        describe("key fetch function") {
            var apiClientMock: APIClientMock!
            var fetcher: SignatureFetcher!
            let config = SignatureFetcher.Config(baseURL: URL(string: mockHost)!, subscriptionKey: "my-subkey")

            beforeEach {
                apiClientMock = APIClientMock()
                fetcher = SignatureFetcher(apiClient: apiClientMock, config: config)
            }

            afterEach {
                UserDefaults.standard.removePersistentDomain(forName: "FetcherSpec")
            }

            it("will call the send function of the api client passing in a request") {
                fetcher.fetchKey(with: "key", completionHandler: { (_) in
                })

                expect(apiClientMock.request).toEventually(beAnInstanceOf(URLRequest.self), timeout: .seconds(5))
            }

            it("will pass nil in the completion handler when environment is incorrectly configured") {
                var resultSuccess: Bool?

                fetcher.fetchKey(with: "key", completionHandler: { (result) in
                    switch result {
                    case .success:
                        resultSuccess = true
                    case .failure:
                        resultSuccess = false
                    }
                })

                expect(resultSuccess).to(be(false))
            }

            it("will prefix ras- to the request's subscription key header") {
                fetcher.fetchKey(with: "key", completionHandler: { (_) in
                })
                expect(apiClientMock.request?.allHTTPHeaderFields!["apiKey"]).toEventually(equal("ras-my-subkey"), timeout: .seconds(5))
            }

            it("will not add (another) ras- prefix to the subscription key, if it already exists") {
                fetcher = SignatureFetcher(apiClient: apiClientMock,
                                  config: .init(baseURL: URL(string: mockHost)!, subscriptionKey: "ras-my-subkey"))

                fetcher.fetchKey(with: "key", completionHandler: { (_) in
                })
                expect(apiClientMock.request?.allHTTPHeaderFields!["apiKey"]).toEventually(equal("ras-my-subkey"))
            }

            context("when valid key model is received as the result from the api client") {
                beforeEach {
                    let dataString = """
                        {"id":"foo","ecKey":"myKeyId","pemKey":"myPemKey"}
                        """
                    apiClientMock.data = dataString.data(using: .utf8)
                }

                it("will set the config dictionary in the result passed to the completion handler") {
                    var testResult: Any?

                    fetcher.fetchKey(with: "key", completionHandler: { (result) in
                        switch result {
                        case .success(let res):
                            testResult = res
                        case .failure:
                            testResult = nil
                        }
                    })

                    expect((testResult as? KeyModel)?.key).toEventually(equal("myKeyId"))
                }
            }

            context("when error is received as the result from the api client") {
                beforeEach {
                    apiClientMock.error = NSError(domain: "Test", code: 123, userInfo: nil)
                }

                it("will pass an error to the completion handler") {
                    var testResult: NSError?

                    fetcher.fetchKey(with: "key", completionHandler: { (result) in
                        switch result {
                        case .success:
                            testResult = nil
                        case .failure(let error):
                            testResult = error as NSError
                        }
                    })

                    expect(testResult?.code).to(be(123))
                }
            }
        }
    }
    #endif
}
