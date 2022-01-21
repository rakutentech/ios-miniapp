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

            beforeEach {
                mockAPIClient.metaData = mockMetaDataString.data(using: .utf8)
                updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .userName, status: .allowed)
                updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .profilePhoto, status: .allowed)
            }
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
                it("will return an Error") {
                    var testError: MASDKError?
                    mockAPIClient.data = nil
                    realMiniApp.getMiniApp(miniAppId: "123", completionHandler: { (result) in
                            switch result {
                            case .success:
                                break
                            case .failure(let error):
                                testError = error
                        }
                    })
                    expect(testError).toEventuallyNot(beNil())
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
                let config = MiniAppSdkConfig(rasProjectId: "dummyId", subscriptionKey: "dummyKey", hostAppVersion: "dummyHostVersion")
                config.rasProjectId = nil
                config.subscriptionKey = nil
                config.hostAppVersion = nil
                config.baseUrl = nil
                it("will reset environment to default") {
                    realMiniApp.update(with: config)
                    expect(realMiniApp.miniAppClient.environment.customUrl).to(beNil())
                    expect(realMiniApp.miniAppClient.environment.customProjectId).to(beNil())
                    expect(realMiniApp.miniAppClient.environment.customSubscriptionKey).to(beNil())
                    expect(realMiniApp.miniAppClient.environment.customAppVersion).to(beNil())
                }
            }
            context("when createMiniApp is called with valid Mini App id but without MessageInterface") {
                it("will return valid Mini App View instance with a default hostAppMessageDelegate and getUniqueId() will return an error message") {
                    let responseString = """
                    [{
                        "id": "\(mockMiniAppInfo.id)",
                        "displayName": "Test",
                        "icon": "https://test.com",
                        "version": {
                            "versionTag": "1.0.0",
                            "versionId": "\(mockMiniAppInfo.version.versionId)",
                        }
                      }]
                    """
                    let manifestResponse = """
                      {
                        "manifest": ["\(mockHost)/map-published-v2/min-abc/ver-abc/HelloWorld.txt"]
                      }
                    """
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .userName, status: .allowed)
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .profilePhoto, status: .allowed)

                    mockAPIClient.data = responseString.data(using: .utf8)
                    mockAPIClient.metaData = mockMetaDataString.data(using: .utf8)
                    mockAPIClient.manifestData = manifestResponse.data(using: .utf8)
                    var responseData: RealMiniAppView?
                    realMiniApp.createMiniApp(appInfo: mockMiniAppInfo, completionHandler: { (result) in
                        switch result {
                        case .success(let response):
                            responseData = response as? RealMiniAppView
                        case .failure:
                            fail("create MiniApp failure")
                        }
                    })
                    expect(responseData).toEventually(beAnInstanceOf(RealMiniAppView.self), timeout: .seconds(6))
                    if let rmap = responseData {
                        expect(rmap.hostAppMessageDelegate).notTo(beNil())
                        var uniqueID: String? = "tmp"
                        rmap.hostAppMessageDelegate?.getUniqueId { (result) in
                            switch result {
                            case .success(let uid):
                                uniqueID = uid
                            case .failure(let error):
                                uniqueID = nil
                                expect(error.errorDescription).to(contain(MASDKLocale.localize(.failedToConformToProtocol)))
                            }
                        }
                        expect(uniqueID).toEventually(beNil())
                    } else {
                        fail("create RealMiniAppView failure")
                    }
                }
            }

            context("when createMiniApp is called with appInfo helper") {
                it("will return valid Mini App View instance with a default hostAppMessageDelegate and getUniqueId() will return an error message") {
                    let responseString = """
                    [{
                        "id": "\(mockMiniAppInfo.id)",
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
                        "manifest": ["\(mockHost)/map-published-v2/min-abc/ver-abc/HelloWorld.txt"]
                      }
                    """
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .userName, status: .allowed)
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .profilePhoto, status: .allowed)
                    mockAPIClient.data = responseString.data(using: .utf8)
                    mockAPIClient.manifestData = manifestResponse.data(using: .utf8)
                    mockAPIClient.metaData = mockMetaDataString.data(using: .utf8)
                    var responseInfo: RealMiniAppView?
                    realMiniApp.createMiniApp(appInfo: mockMiniAppInfo, completionHandler: { (result) in
                        switch result {
                        case .success(let responseData):
                            responseInfo = responseData as? RealMiniAppView
                        case .failure:
                            fail("create MiniApp failure")
                        }
                    })
                    expect(responseInfo).toEventually(beAnInstanceOf(RealMiniAppView.self), timeout: .seconds(6))
                    if let rmap = responseInfo {
                        expect(rmap.hostAppMessageDelegate).notTo(beNil())
                        rmap.hostAppMessageDelegate?.getUniqueId { (result) in
                            switch result {
                            case .success: break
                            case .failure(let error):
                                expect(error.errorDescription).to(contain(MASDKLocale.localize(.failedToConformToProtocol)))
                            }
                        }
                    } else {
                        fail("create RealMiniAppView failure")
                    }
                }
            }

            context("when createMiniApp is called with appInfo helper") {
                it("will return valid Mini App View instance with a default hostAppMessageDelegate and getUniqueId() will return an error message") {
                    let responseString = """
                    [{
                        "id": "\(mockMiniAppInfo.id)",
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
                        "manifest": ["\(mockHost)/map-published-v2/min-abc/ver-abc/HelloWorld.txt"]
                      }
                    """
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .userName, status: .allowed)
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .profilePhoto, status: .allowed)
                    mockAPIClient.data = responseString.data(using: .utf8)
                    mockAPIClient.manifestData = manifestResponse.data(using: .utf8)
                    mockAPIClient.metaData = mockMetaDataString.data(using: .utf8)
                    var responseInfo: RealMiniAppView?
                    waitUntil(timeout: .seconds(5)) { done in
                        realMiniApp.createMiniApp(appInfo: mockMiniAppInfo, completionHandler: { (result) in
                            switch result {
                            case .success(let responseData):
                                responseInfo = responseData as? RealMiniAppView
                                expect(responseData).to(beAnInstanceOf(RealMiniAppView.self))
                                done()
                            case .failure:
                                fail("create MiniApp failure")
                            }
                        })
                    }
                    var uniqueID: String? = "tmp"
                    var errorInfo: MASDKError?
                    if let rmap = responseInfo {
                        expect(rmap.hostAppMessageDelegate).notTo(beNil())
                        rmap.hostAppMessageDelegate?.getUniqueId { (result) in
                            switch result {
                            case .success(let uid):
                                uniqueID = uid
                            case .failure(let error):
                                uniqueID = nil
                                errorInfo = error
                            }
                        }
                    } else {
                        fail("create RealMiniAppView failure")
                    }
                    expect(uniqueID).toEventually(beNil())
                    expect(errorInfo?.errorDescription).to(contain(MASDKLocale.localize(.failedToConformToProtocol)))
                }
            }

            context("when createMiniApp is called with valid Mini App id and real mini app validates with platform for the latest version and if the versions are same") {
                it("will download mini app with the mini app info that is passed on") {
                    let responseString = """
                    [{
                        "id": "\(mockMiniAppInfo.id)",
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
                        "manifest": ["\(mockHost)/map-published-v2/min-abc/ver-abc/HelloWorld.txt"]
                      }
                    """
                    mockAPIClient.data = responseString.data(using: .utf8)
                    mockAPIClient.manifestData = manifestResponse.data(using: .utf8)
                    var testResultData: MiniAppDisplayDelegate?
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
                        "id": "\(mockMiniAppInfo.id)",
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
                        "manifest": ["\(mockHost)/map-published-v2/min-abc/ver-abc/HelloWorld.txt"]
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
                        "id": "\(mockMiniAppInfo.id)",
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
                        "manifest": ["\(mockHost)/map-published-v2/min-abc/ver-abc/HelloWorld.txt"]
                      }
                    """
                    realMiniApp.miniAppInfoFetcher = mockMiniAppInfoFetcher
                    mockMiniAppInfoFetcher.error = MASDKError.unknownError(domain: "URLErrorDomain", code: -1009, description: "")
                    mockAPIClient.data = responseString.data(using: .utf8)
                    mockAPIClient.manifestData = manifestResponse.data(using: .utf8)
                    var testError: MASDKError?
                    realMiniApp.createMiniApp(appId: mockMiniAppInfo.id, completionHandler: { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error
                        }
                    }, messageInterface: mockMessageInterface)
                    expect(testError).toEventuallyNot(beNil())
                    mockMiniAppInfoFetcher.error = nil
                }
            }
            context("when createMiniApp is called with valid Mini App Info") {
                it("will return valid Mini App View instance") {

                    let responseString = """
                    [{
                        "id": "\(mockMiniAppInfo.id)",
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
                        "manifest": ["\(mockHost)/map-published-v2/min-abc/ver-abc/HelloWorld.txt"]
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
                        "manifest": ["\(mockHost)/app-id-test/ver-id-test/HelloWorld.txt"]
                      }
                    """
                    var testError: MASDKError?
                    mockAPIClient.data = responseString.data(using: .utf8)
                    realMiniApp.createMiniApp(appId: mockMiniAppInfo.id, completionHandler: { (result) in
                            switch result {
                            case .success:
                                break
                            case .failure(let error):
                                testError = error
                        }
                    }, messageInterface: mockMessageInterface)
                    expect(testError?.errorDescription).toEventually(equal(MASDKError.invalidResponseData.errorDescription), timeout: .seconds(2))
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
                    var testError: MASDKError?
                    mockedDisplayer.mockedInitialLoadCallbackResponse = false
                    _ = realMiniApp.createMiniApp(url: URL(string: "http://miniapp")!,
                                              errorHandler: { error in
                        testError = error
                    }, messageInterface: mockMessageInterface)
                    expect(testError?.errorDescription).toEventually(equal(MASDKError.invalidURLError.errorDescription), timeout: .seconds(2))
                }
            }
        }
    }
}
