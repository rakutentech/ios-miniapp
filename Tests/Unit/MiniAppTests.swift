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
                it("will return nil") {
                    var testError: NSError?
                    MiniApp.shared().info(miniAppId: "") { (result) in
                        switch result {
                        case .success: break
                        case .failure(let error):
                            testError = error as NSError
                        }
                    }
                    expect(testError?.localizedDescription).toEventually(equal("Invalid AppID error"), timeout: 2)
                }
            }
            context("when info method is called with valid mini app id") {
                it("will return nil") {
                    var testError: NSError?
                    MiniApp.shared().info(miniAppId: "1234") { (result) in
                        switch result {
                        case .success: break
                        case .failure(let error):
                            testError = error as NSError
                        }
                    }
                    expect(testError?.code).toEventually(equal(400) || equal(404), timeout: 10)
                }
            }

        }
    }
}
