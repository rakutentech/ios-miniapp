import Quick
import Nimble
@testable import MiniApp

class MiniAppTests: QuickSpec {

    override func spec() {
        describe("MiniApp tests") {
            context("when getPermissions is called with empty mini app id") {
                it("will return nil") {
                    let miniAppCustomPermissions = MiniApp.shared().getCustomPermissions(forMiniApp: "")
                    expect(miniAppCustomPermissions).toEventually(equal([]))
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
                    expect(miniAppCustomPermissions.count).toEventually(equal(MiniAppCustomPermissionType.allCases.count))
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
        }
    }
}
