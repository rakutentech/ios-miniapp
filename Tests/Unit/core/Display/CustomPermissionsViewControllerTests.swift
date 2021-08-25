import Quick
import Nimble
@testable import MiniApp

class CustomPermissionsViewControllerTests: QuickSpec {

    override func spec() {
        let requiredPermissions: [MASDKCustomPermissionModel] = [MASDKCustomPermissionModel(permissionName: .userName,
                                                                                            isPermissionGranted: .allowed,
                                                                                            permissionRequestDescription: "User name custom permission"),
                                                                 MASDKCustomPermissionModel(permissionName: .profilePhoto,
                                                                                            isPermissionGranted: .allowed,
                                                                                            permissionRequestDescription: "Profile Photo custom permission")]
        describe("CustomPermissionsViewControllerTests") {
            let customPermissionsController = CustomPermissionsRequestViewController()
            customPermissionsController.permissionsRequestList = requiredPermissions
            context("when isAllPermissionsDenied method is called") {
                it("will webview config") {
                    let toggleSwitch = UISwitch()
                    toggleSwitch.isOn = false
                    toggleSwitch.tag = 0
                    expect(customPermissionsController.isAllPermissionsDenied(toggleSwitch)).to(equal(false))
                    toggleSwitch.tag = 1
                    expect(customPermissionsController.isAllPermissionsDenied(toggleSwitch)).to(equal(true))
                    toggleSwitch.isOn = true
                    expect(customPermissionsController.isAllPermissionsDenied(toggleSwitch)).to(equal(false))
                }
            }
        }
    }
}
