import Quick
import Nimble
@testable import MiniApp

// swiftlint:disable function_body_length
class MiniAppTests: QuickSpec {

    override func spec() {
        let miniAppKeyStore = MiniAppPermissionsStorage()

        describe("MiniApp tests") {
            beforeEach {
                miniAppKeyStore.removeKey(for: mockMiniAppInfo.id)
            }
            context("when getPermissions is called with empty mini app id") {
                it("will return nil") {
                    let miniAppCustomPermissions = MiniApp.shared().getCustomPermissions(forMiniApp: "")
                    expect(miniAppCustomPermissions).to(equal([]))
                }
            }
            context("when info method is called with empty mini app id") {
                it("will return an error") {
                    var testError: MASDKError?
                    MiniApp.shared().info(miniAppId: "") { (result) in
                        switch result {
                        case .success: break
                        case .failure(let error):
                            testError = error
                        }
                    }
                    expect(testError?.localizedDescription).toEventually(equal(MASDKError.invalidAppId.localizedDescription), timeout: .seconds(2))
                }
            }
            context("when no mini apps downloaded and listDownloadedWithCustomPermissions method is called") {
                it("will return nil") {
                    let list = MiniApp.shared().listDownloadedWithCustomPermissions()
                    expect(list).to(beAKindOf(MASDKDownloadedListPermissionsPair.self))
                }
            }
            context("when getMiniAppManifest is called with invalid miniappId") {
                it("will return invalidAppId error") {
                    var testError: MASDKError?
                    MiniApp.shared().getMiniAppManifest(miniAppId: "", miniAppVersion: "", completionHandler: { (result) in
                        switch result {
                        case .success: break
                        case .failure(let error):
                            testError = error
                        }
                    })
                    expect(testError?.localizedDescription).to(equal(MASDKError.invalidAppId.localizedDescription))
                }
            }
            context("when getMiniAppManifest is called with invalid miniapp versionId") {
                it("will return invalidVersionId error") {
                    var testError: MASDKError?
                    MiniApp.shared().getMiniAppManifest(miniAppId: "abc", miniAppVersion: "", completionHandler: { (result) in
                        switch result {
                        case .success: break
                        case .failure(let error):
                            testError = error
                        }
                    })
                    expect(testError?.localizedDescription).to(equal(MASDKError.invalidVersionId.localizedDescription))
                }
            }
            context("when setCustomPermissions is called with valid miniapp Id") {
                it("will not store the permission") {
                    MiniApp.shared().setCustomPermissions(forMiniApp: mockMiniAppInfo.id,
                                                          permissionList: [MASDKCustomPermissionModel(
                                                                            permissionName: .userName,
                                                                            isPermissionGranted: .allowed,
                                                                            permissionRequestDescription: "")])
                    let customPermissionList = MiniApp.shared().getCustomPermissions(forMiniApp: mockMiniAppInfo.id)
                    expect(customPermissionList.count).to(equal(1))
                }
            }
            context("when setCustomPermissions is called with invalid miniapp Id") {
                it("will not store the permission") {
                    MiniApp.shared().setCustomPermissions(forMiniApp: "",
                                                          permissionList: [MASDKCustomPermissionModel(
                                                                            permissionName: .userName,
                                                                            isPermissionGranted: .allowed,
                                                                            permissionRequestDescription: "")])
                    let customPermissionList = MiniApp.shared().getCustomPermissions(forMiniApp: mockMiniAppInfo.id)
                    expect(customPermissionList.count).to(equal(0))
                }
            }
            context("when createMiniapp is called with invalid miniapp appId") {
                it("will return invalidAppId error") {
                    var testError: MASDKError?
                    let mockMessageInterface = MockMessageInterface()
                    MiniApp.shared().create(appId: "", completionHandler: { (result) in
                        switch result {
                        case .success: break
                        case .failure(let error):
                            testError = error
                        }
                    }, messageInterface: mockMessageInterface)
                    expect(testError?.localizedDescription).toEventually(equal(MASDKError.invalidAppId.localizedDescription), timeout: .seconds(5))
                }
            }
            context("when createMiniapp is called with invalid miniapp version") {
                it("will return invalidAppId error") {
                    var testError: MASDKError?
                    let mockMessageInterface = MockMessageInterface()
                    MiniApp.shared().create(appId: "1", version: "", queryParams: nil, completionHandler: { (result) in
                        switch result {
                        case .success: break
                        case .failure(let error):
                            testError = error
                            print("")
                        }
                    }, messageInterface: mockMessageInterface, adsDisplayer: nil)
                    expect(testError?.localizedDescription).toEventuallyNot(beNil(), timeout: .seconds(5))
                }
            }
            context("when createMiniapp is called with invalid miniapp version") {
                it("will return invalidAppId error") {
                    var testError: MASDKError?
                    let mockMessageInterface = MockMessageInterface()
                    MiniApp.shared().create(appId: "1", version: "1", queryParams: nil, completionHandler: { (result) in
                        switch result {
                        case .success: break
                        case .failure(let error):
                            testError = error
                        }
                    }, messageInterface: mockMessageInterface, adsDisplayer: nil)
                    expect(testError?.localizedDescription).toEventuallyNot(beNil(), timeout: .seconds(5))
                }
            }
            context("when createMiniapp is called with invalid miniapp Info") {
                it("will return invalidAppId error") {
                    var testError: Error?
                    let mockMessageInterface = MockMessageInterface()
                    MiniApp.shared().create(appInfo: mockMiniAppInfo, completionHandler: { (result) in
                        switch result {
                        case .success: break
                        case .failure(let error):
                            testError = error
                        }
                    }, messageInterface: mockMessageInterface, adsDisplayer: nil)
                    expect(testError?.localizedDescription).toEventuallyNot(beNil(), timeout: .seconds(5))
                }
            }
            context("when MiniAppInfo model object is created") {
                it("is comparable using their respective IDs") {
                    let miniAppInfo  = MiniAppInfo(id: "Rakuten",
                                                   displayName: "Test",
                                                   icon: URL(string: "https://www.rakuten.co.jp/")!,
                                                   version: Version(versionTag: "", versionId: ""))
                    let miniAppInfoType2  = MiniAppInfo(id: "Rakuten",
                                                        displayName: "Test",
                                                        icon: URL(string: "https://www.rakuten.co.jp/")!,
                                                        version: Version(versionTag: "", versionId: ""))
                    expect(miniAppInfo).to(equal(miniAppInfoType2))
                    expect(miniAppInfo).toEventuallyNot(equal(mockMiniAppInfo))
                }
            }
            context("when getMiniAppPreviewInfo is called with invalid token") {
                it("will return server error") {
                    var testError: MASDKError?
                    MiniApp.shared().getMiniAppPreviewInfo(using: "TOKEN", completionHandler: { (result) in
                        switch result {
                        case .success: break
                        case .failure(let error):
                            testError = error
                        }
                    })
                    expect(testError?.localizedDescription).toEventuallyNot(beNil(), timeout: .seconds(5))
                }
            }
        }
    }
}
