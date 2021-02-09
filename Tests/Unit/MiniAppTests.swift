import Quick
import Nimble
@testable import MiniApp

// swiftlint:disable function_body_length
class MiniAppTests: QuickSpec {

    override func spec() {
        describe("MiniApp tests") {
            context("when getPermissions is called with empty mini app id") {
                it("will return nil") {
                    let miniAppCustomPermissions = MiniApp.shared().getCustomPermissions(forMiniApp: "")
                    expect(miniAppCustomPermissions).to(equal([]))
                }
            }
            context("when getPermissions is called with valid mini app id that has stored permissions") {
                it("will return list of custom permissions") {
                    let userNamePermission = MASDKCustomPermissionModel(permissionName: MiniAppCustomPermissionType(rawValue: MiniAppCustomPermissionType.contactsList.rawValue)!)
                    let profilePhotoPermission = MASDKCustomPermissionModel(
                        permissionName: MiniAppCustomPermissionType(rawValue: MiniAppCustomPermissionType.profilePhoto.rawValue)!,
                        isPermissionGranted: MiniAppCustomPermissionGrantedStatus.denied)
                    MiniApp.shared().setCustomPermissions(forMiniApp: "123", permissionList: [userNamePermission, profilePhotoPermission])
                    let miniAppCustomPermissions = MiniApp.shared().getCustomPermissions(forMiniApp: "123")
                    expect(miniAppCustomPermissions.count).to(equal(MiniAppCustomPermissionType.allCases.count))
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
        }
    }
}
