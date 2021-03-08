import Quick
import Nimble
@testable import MiniApp

// swiftlint:disable function_body_length
class RealMiniAppPermissionTests: QuickSpec {
    override func spec() {
        describe("Real mini app permissions tests") {
            let realMiniApp = RealMiniApp()
            context("when RealMiniApp class has no message interface method object and when requestPermission is called") {
                it("will return error") {
                    var testError: MASDKPermissionError?
                    realMiniApp.requestDevicePermission(permissionType: MiniAppDevicePermissionType.init(rawValue: "location")!) { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error
                        }
                    }
                    expect(MASDKPermissionError(rawValue: testError?.rawValue ?? "")).toEventually(equal(MASDKPermissionError.failedToConformToProtocol))
                }
            }
            context("when RealMiniApp class has no message interface method object and when requestCustomPermissions is called") {
                it("will return error") {
                    var testError: MASDKCustomPermissionError?
                    realMiniApp.requestCustomPermissions(permissions: []) { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error
                        }
                    }
                    expect(MASDKCustomPermissionError(rawValue: testError?.rawValue ?? "")).toEventually(equal(MASDKCustomPermissionError.failedToConformToProtocol))
                }
            }
            context("when RealMiniApp class has no message interface method object and when requestCustomPermissions is called") {
                it("will return error") {
                    var testError: NSError?
                    realMiniApp.shareContent(info: MiniAppShareContent(
                        messageContent: "Testing the sample app")) { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            testError = error as NSError
                        }
                    }
                    expect(testError?.code).toEventually(equal(0))
                }
            }
            context("when we store permission") {
                it("will store them persistently") {
                    realMiniApp.miniAppManifest = mockMiniAppManifest
                    realMiniApp.storeCustomPermissions(
                        forMiniApp: "test",
                        permissionList: [MASDKCustomPermissionModel(permissionName: .userName, isPermissionGranted: .allowed, permissionRequestDescription: "permissionDesc")])
                    let permissions = realMiniApp.retrieveCustomPermissions(forMiniApp: "test")
                    expect(permissions[0].permissionName).to(equal(.userName))
                    expect(permissions[0].isPermissionGranted).to(equal(.allowed))
                }
            }
        }
    }
}
