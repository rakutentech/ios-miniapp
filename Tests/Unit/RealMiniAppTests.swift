import Quick
import Nimble
@testable import MiniApp

// swiftlint:disable function_body_length
// swiftlint:disable file_length
// swiftlint:disable cyclomatic_complexity
// swiftlint:disable type_body_length
class RealMiniAppTests: QuickSpec {

    override func spec() {
        let miniAppStatus = MiniAppStatus()
        describe("Real mini app tests") {
            afterEach {
                deleteMockMiniApp(appId: mockMiniAppInfo.id, versionId: mockMiniAppInfo.version.versionId)
                deleteStatusPreferences()
            }
            let realMiniApp = RealMiniApp()
            let mockAPIClient = MockAPIClient()
            let mockMiniAppInfoFetcher = MockMiniAppInfoFetcher()
            realMiniApp.miniAppClient = mockAPIClient
            let mockManifestDownloader = MockManifestDownloader()
            let downloader = MiniAppDownloader(apiClient: mockAPIClient, manifestDownloader: mockManifestDownloader, status: miniAppStatus)
            realMiniApp.manifestDownloader = mockManifestDownloader
            realMiniApp.miniAppDownloader = downloader
            let mockMessageInterface = MockMessageInterface()

            context("when getMiniApp is called with valid app id") {
                it("will return valid MiniAppInfo") {
                    var decodedResponse: MiniAppInfo?
                    let responseString = """
                    [{
                        "id": "123",
                        "displayName": "Test",
                        "icon": "https://test.com",
                        "version": {
                            "versionTag": "1.0.0",
                            "versionId": "455"
                        }
                      }]
                    """
                    mockAPIClient.data = responseString.data(using: .utf8)
                    realMiniApp.getMiniApp(miniAppId: "123", completionHandler: { (result) in
                            switch result {
                            case .success(let responseData):
                                decodedResponse = responseData
                            case .failure:
                                break
                        }
                    })
                    expect(decodedResponse).toEventually(beAnInstanceOf(MiniAppInfo.self))
                }
            }
            context("when getMiniApp is called with invalid app id") {
                it("will return valid MiniAppInfo") {
                    var testError: NSError?
                    mockAPIClient.data = nil
                    realMiniApp.getMiniApp(miniAppId: "123", completionHandler: { (result) in
                            switch result {
                            case .success:
                                break
                            case .failure(let error):
                                testError = error as NSError
                        }
                    })
                    expect(testError?.code).toEventually(equal(0))
                }
            }
            context("when listMiniApp is called") {
                it("will return a list of MiniAppInfo") {
                    let responseString =  """
                    [{
                        "id": "123",
                        "displayName": "Test",
                        "icon": "https://test.com",
                        "version": {
                            "versionTag": "1.0.0",
                            "versionId": "455"
                        }
                      },
                      {
                        "id": "456",
                        "displayName": "Test2",
                        "icon": "https://test2.com",
                        "version": {
                            "versionTag": "1.0.0",
                            "versionId": "555"
                        }
                      }]
                    """
                    mockAPIClient.data = responseString.data(using: .utf8)
                    waitUntil { done in
                        realMiniApp.listMiniApp { (result) in
                            switch result {
                            case .success(let responseData):
                                expect(responseData).to(beAnInstanceOf([MiniAppInfo].self))
                                done()
                            case .failure:
                                fail("get MiniApp list failure")
                            }
                        }
                    }
                }
            }
            context("when I update RealMiniApp with MiniAppSdkConfig") {
                let config = MiniAppSdkConfig(baseUrl: "http://test1/", rasProjectId: "customProjectId", subscriptionKey: "dummyKey", hostAppVersion: "dummyHostVersion")
                it("will take the new settings in account") {
                    realMiniApp.update(with: config)
                    expect(realMiniApp.miniAppClient.environment.customUrl) == "http://test1/"
                    expect(realMiniApp.miniAppClient.environment.customProjectId) == "customProjectId"
                    expect(realMiniApp.miniAppClient.environment.customSubscriptionKey) == "dummyKey"
                    expect(realMiniApp.miniAppClient.environment.customAppVersion) == "dummyHostVersion"
                }
            }
            context("when I update RealMiniApp with MiniAppNavigationConfig") {
                let dummyView = MockNavigationView(frame: .zero)
                let config = MiniAppNavigationConfig()
                config.navigationBarVisibility = .always
                config.navigationDelegate = dummyView
                config.navigationView = dummyView

                it("will take the new navigation settings in account") {
                    realMiniApp.update(with: nil, navigationSettings: config)
                    expect(realMiniApp.displayer.navConfig?.navigationBarVisibility) == .always
                    expect(realMiniApp.displayer.navConfig?.navigationDelegate).to(beAKindOf(MiniAppNavigationDelegate.self))
                    expect(realMiniApp.displayer.navConfig?.navigationView).to(beAKindOf(MiniAppNavigationDelegate.self))

                }
            }
            context("when set config parameters of MiniAppSdkConfig passed to RealMiniApp to empty values") {
                let config = MiniAppSdkConfig(rasAppId: "dummyId", subscriptionKey: "dummyKey", hostAppVersion: "dummyHostVersion")
                config.rasAppId = nil
                config.subscriptionKey = nil
                config.hostAppVersion = nil
                config.baseUrl = nil
                it("will reset environment to default") {
                    realMiniApp.update(with: config)
                    expect(realMiniApp.miniAppClient.environment.customUrl).to(beNil())
                    expect(realMiniApp.miniAppClient.environment.customAppId).to(beNil())
                    expect(realMiniApp.miniAppClient.environment.customSubscriptionKey).to(beNil())
                    expect(realMiniApp.miniAppClient.environment.customAppVersion).to(beNil())
                }
            }
            context("when createMiniApp is called with valid Mini App id but without MessageInterface") {
                it("will return valid Mini App View instance with a default hostAppMessageDelegate and getUniqueId() will return an error message") {
                    let responseString = """
                    [{
                        "id": "123",
                        "displayName": "Test",
                        "icon": "https://test.com",
                        "version": {
                            "versionTag": "1.0.0",
                            "versionId": "455"
                        }
                      }]
                    """
                    let manifestResponse = """
                      {
                        "manifest": ["https://google.com/map-published-v2/min-abc/ver-abc/HelloWorld.txt"]
                      }
                    """
                    mockAPIClient.data = responseString.data(using: .utf8)
                    mockAPIClient.manifestData = manifestResponse.data(using: .utf8)
                    waitUntil { done in
                        realMiniApp.createMiniApp(appId: mockMiniAppInfo.id, completionHandler: { (result) in
                            switch result {
                            case .success(let responseData):
                                expect(responseData).to(beAnInstanceOf(RealMiniAppView.self))
                                if let rmap = responseData as? RealMiniAppView {
                                    expect(rmap.hostAppMessageDelegate).notTo(beNil())
                                    expect(UUID(uuidString: rmap.hostAppMessageDelegate!.getUniqueId())).to(beNil())
                                } else {
                                    fail("create RealMiniAppView failure")
                                }
                                done()
                            case .failure:
                                fail("create MiniApp failure")
                            }
                        })
                    }
                }
            }

            context("when createMiniApp is called with appInfo helper") {
                it("will return valid Mini App View instance with a default hostAppMessageDelegate and getUniqueId() will return an error message") {
                    let responseString = """
                    [{
                        "id": "123",
                        "displayName": "Test",
                        "icon": "https://test.com",
                        "version": {
                            "versionTag": "1.0.0",
                            "versionId": "ver-id-test"
                        }
                      }]
                    """
                    let manifestResponse = """
                      {
                        "manifest": ["https://google.com/map-published-v2/min-abc/ver-abc/HelloWorld.txt"]
                      }
                    """
                    mockAPIClient.data = responseString.data(using: .utf8)
                    mockAPIClient.manifestData = manifestResponse.data(using: .utf8)
                    waitUntil { done in
                        realMiniApp.createMiniApp(appInfo: mockMiniAppInfo, completionHandler: { (result) in
                            switch result {
                            case .success(let responseData):
                                expect(responseData).to(beAnInstanceOf(RealMiniAppView.self))
                                if let rmap = responseData as? RealMiniAppView {
                                    expect(rmap.hostAppMessageDelegate).notTo(beNil())
                                    expect(UUID(uuidString: rmap.hostAppMessageDelegate!.getUniqueId())).to(beNil())
                                } else {
                                    fail("create RealMiniAppView failure")
                                }
                                done()
                            case .failure:
                                fail("create MiniApp failure")
                            }
                        })
                    }
                }
            }

            context("when createMiniApp is called with valid Mini App id and real mini app validates with platform for the latest version and if the versions are same") {
                it("will download mini app with the mini app info that is passed on") {
                    let responseString = """
                    [{
                        "id": "123",
                        "displayName": "Test",
                        "icon": "https://test.com",
                        "version": {
                            "versionTag": "1.0.0",
                            "versionId": "ver-id-test"
                        }
                      }]
                    """
                    let manifestResponse = """
                      {
                        "manifest": ["https://google.com/map-published-v2/min-abc/ver-abc/HelloWorld.txt"]
                      }
                    """
                    mockAPIClient.data = responseString.data(using: .utf8)
                    mockAPIClient.manifestData = manifestResponse.data(using: .utf8)
                    var testResultData: MiniAppDisplayProtocol?
                    realMiniApp.createMiniApp(appId: mockMiniAppInfo.id, completionHandler: { (result) in
                        switch result {
                        case .success(let responseData):
                            testResultData = responseData
                        case .failure:
                            break
                        }
                    })
                    expect(testResultData).toEventually(beAnInstanceOf(RealMiniAppView.self), timeout: .seconds(20))
                }
            }

            context("when createMiniApp is called with valid Mini App id") {
                it("will return valid Mini App View instance") {

                    let responseString = """
                    [{
                        "id": "123",
                        "displayName": "Test",
                        "icon": "https://test.com",
                        "version": {
                            "versionTag": "1.0.0",
                            "versionId": "455"
                        }
                      }]
                    """
                    let manifestResponse = """
                      {
                        "manifest": ["https://google.com/map-published-v2/min-abc/ver-abc/HelloWorld.txt"]
                      }
                    """
                    mockAPIClient.data = responseString.data(using: .utf8)
                    mockAPIClient.manifestData = manifestResponse.data(using: .utf8)
                    waitUntil { done in
                        realMiniApp.createMiniApp(appId: mockMiniAppInfo.id, completionHandler: { (result) in
                            switch result {
                            case .success(let responseData):
                                expect(responseData).to(beAnInstanceOf(RealMiniAppView.self))
                                done()
                            case .failure:
                                fail("create MiniApp failure")
                            }
                        }, messageInterface: mockMessageInterface)
                    }
                }
            }
            context("when createMiniApp is called with valid Mini App Id but failed due to offline network error") {
                it("will return error") {
                    let responseString = """
                    [{
                        "id": "123",
                        "displayName": "Test",
                        "icon": "https://test.com",
                        "version": {
                            "versionTag": "1.0.0",
                            "versionId": "455"
                        }
                      }]
                    """
                    let manifestResponse = """
                      {
                        "manifest": ["https://google.com/map-published-v2/min-abc/ver-abc/HelloWorld.txt"]
                      }
                    """
                    realMiniApp.miniAppInfoFetcher = mockMiniAppInfoFetcher
                    mockMiniAppInfoFetcher.error = NSError(domain: "URLErrorDomain", code: -1009, userInfo: nil)
                    mockAPIClient.data = responseString.data(using: .utf8)
                    mockAPIClient.manifestData = manifestResponse.data(using: .utf8)
                    var testError: NSError?
                    realMiniApp.createMiniApp(appId: mockMiniAppInfo.id, completionHandler: { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error as NSError
                        }
                    }, messageInterface: mockMessageInterface)
                    expect(testError?.code).toEventually(equal(-1009), timeout: .seconds(10))
                    mockMiniAppInfoFetcher.error = nil
                }
            }
            context("when createMiniApp is called with valid Mini App Info") {
                it("will return valid Mini App View instance") {

                    let responseString = """
                    [{
                        "id": "123",
                        "displayName": "Test",
                        "icon": "https://test.com",
                        "version": {
                            "versionTag": "1.0.0",
                            "versionId": "455"
                        }
                      }]
                    """
                    let manifestResponse = """
                      {
                        "manifest": ["https://google.com/map-published-v2/min-abc/ver-abc/HelloWorld.txt"]
                      }
                    """
                    mockAPIClient.data = responseString.data(using: .utf8)
                    mockAPIClient.manifestData = manifestResponse.data(using: .utf8)
                    waitUntil { done in
                        realMiniApp.createMiniApp(appId: "app-id-test", completionHandler: { (result) in
                            switch result {
                            case .success(let responseData):
                                expect(responseData).to(beAnInstanceOf(RealMiniAppView.self))
                                done()
                            case .failure:
                                fail("create MiniApp failure")
                            }
                        }, messageInterface: mockMessageInterface)
                    }
                }
            }
            context("when createMiniApp is called with valid Mini App id but failed because of invalid URLs") {
                it("will return error") {
                    let responseString = """
                      {
                        "manifest": ["https://example.com/app-id-test/ver-id-test/HelloWorld.txt"]
                      }
                    """
                    var testError: NSError?
                    mockAPIClient.data = responseString.data(using: .utf8)
                    realMiniApp.createMiniApp(appId: mockMiniAppInfo.id, completionHandler: { (result) in
                            switch result {
                            case .success:
                                break
                            case .failure(let error):
                                testError = error as NSError
                        }
                    }, messageInterface: mockMessageInterface)
                    expect(testError?.code).toEventually(equal(0))
                }
            }
            context("when createMiniApp is called with url parameter") {
                var originalDisplayer: Displayer!
                var mockedDisplayer: MockDisplayer!

                beforeEach {
                    originalDisplayer = realMiniApp.displayer
                    mockedDisplayer = MockDisplayer()
                    realMiniApp.displayer = mockedDisplayer
                }
                afterEach {
                    realMiniApp.displayer = originalDisplayer
                }

                it("will return an error if initial load of the mini app has failed") {
                    var testError: NSError?
                    mockedDisplayer.mockedInitialLoadCallbackResponse = false
                    _ = realMiniApp.createMiniApp(url: URL(string: "http://miniapp")!,
                                              errorHandler: { error in
                        testError = error as NSError
                    }, messageInterface: mockMessageInterface)
                    expect(testError).toEventually(equal(NSError.invalidURLError()), timeout: .seconds(2))
                }
            }
        }
    }
}
