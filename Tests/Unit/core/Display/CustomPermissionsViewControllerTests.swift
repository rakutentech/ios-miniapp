import Quick
import Nimble
import UIKit
@testable import MiniApp

class CustomPermissionsViewControllerTests: QuickSpec {

    override func spec() {
        let requiredPermissions: [MASDKCustomPermissionModel] = [MASDKCustomPermissionModel(permissionName: .userName,
                                                                                            isPermissionGranted: .allowed,
                                                                                            permissionRequestDescription: "User name custom permission", isOneTimePermission: false),
                                                                 MASDKCustomPermissionModel(permissionName: .profilePhoto,
                                                                                            isPermissionGranted: .allowed,
                                                                                            permissionRequestDescription: "Profile Photo custom permission", isOneTimePermission: false)]
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
