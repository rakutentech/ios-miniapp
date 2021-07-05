import Quick
import Nimble
@testable import MiniApp

class MiniAppTests: QuickSpec {

    // swiftlint:disable function_body_length
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
        }
    }
}
