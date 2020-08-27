import Quick
import Nimble
@testable import MiniApp

// swiftlint:disable function_body_length
class MiniAppStatusTests: QuickSpec {

    override func spec() {
        afterEach {
            deleteStatusPreferences()
        }
        describe("mini app preferences") {
            context("when setDownloadStatus is called") {
                it("will set status true value for given key") {
                    let miniAppStatus = MiniAppStatus()
                    miniAppStatus.setDownloadStatus(true, for: "mini-app/testing")
                    expect(true).toEventually(equal(miniAppStatus.isDownloaded(key: "mini-app/testing")))
                    UserDefaults().removePersistentDomain(forName: "com.rakuten.tech.mobile.miniapp")
                }
                it("will set status false value for given key") {
                    let miniAppStatus = MiniAppStatus()
                    miniAppStatus.setDownloadStatus(false, for: "mini-app/testing")
                    expect(false).toEventually(equal(miniAppStatus.isDownloaded(key: "mini-app/testing")))
                    UserDefaults().removePersistentDomain(forName: "com.rakuten.tech.mobile.miniapp")
                }
                it("will set status true for given appId and versionId") {
                    let miniAppStatus = MiniAppStatus()
                    miniAppStatus.setDownloadStatus(true, appId: "mini-app", versionId: "testing")
                    expect(true).toEventually(equal(miniAppStatus.isDownloaded(appId: "mini-app", versionId: "testing")))
                    UserDefaults().removePersistentDomain(forName: "com.rakuten.tech.mobile.miniapp")
                }
                it("will set status false for given appId and versionId") {
                    let miniAppStatus = MiniAppStatus()
                    miniAppStatus.setDownloadStatus(false, appId: "mini-app", versionId: "testing")
                    expect(false).toEventually(equal(miniAppStatus.isDownloaded(appId: "mini-app", versionId: "testing")))
                    UserDefaults().removePersistentDomain(forName: "com.rakuten.tech.mobile.miniapp")
                }
            }
            context("when unknown key is used") {
                it("will return false") {
                    let miniAppStatus = MiniAppStatus()
                    expect(false).toEventually(equal(miniAppStatus.isDownloaded(key: "Test")))
                    UserDefaults().removePersistentDomain(forName: "com.rakuten.tech.mobile.miniapp")
                }
            }
            context("when mini app info is saved") {
                it("will return the miniapp info for a valid mini app id") {
                    let miniAppStatus = MiniAppStatus()
                    miniAppStatus.saveMiniAppInfo(appInfo: mockMiniAppInfo, key: mockMiniAppInfo.id)
                    let retrievedMiniAppInfo = miniAppStatus.getMiniAppInfo(appId: mockMiniAppInfo.id)
                    expect(retrievedMiniAppInfo?.id).toEventually(equal(mockMiniAppInfo.id))
                    expect(retrievedMiniAppInfo?.version.versionId).toEventually(equal(mockMiniAppInfo.version.versionId))
                    UserDefaults().removePersistentDomain(forName: "com.rakuten.tech.mobile.miniapp.MiniAppDemo.MiniAppInfo")
                }
                it("will return nil for a invalid mini app id") {
                    let miniAppStatus = MiniAppStatus()
                    let retrievedMiniAppInfo = miniAppStatus.getMiniAppInfo(appId: "123")
                    expect(retrievedMiniAppInfo).toEventually(beNil())
                    UserDefaults().removePersistentDomain(forName: "com.rakuten.tech.mobile.miniapp.MiniAppDemo.MiniAppInfo")
                }
            }
            context("when mini app custom permissions info is saved and retrieved") {
                it("will return the miniapp info for a valid mini app id") {
                    let miniAppStatus = MiniAppStatus()
                    let userNamePermission = MASDKCustomPermissionModel(
                        permissionName: MiniAppCustomPermissionType(rawValue: MiniAppCustomPermissionType.userName.rawValue)!)
                    let profilePhotoPermission = MASDKCustomPermissionModel(
                        permissionName: MiniAppCustomPermissionType(rawValue: MiniAppCustomPermissionType.profilePhoto.rawValue)!, isPermissionGranted: MiniAppCustomPermissionGrantedStatus.denied)
                    miniAppStatus.setCustomPermissions(forMiniApp: "123", permissionList: [userNamePermission, profilePhotoPermission])
                    var miniAppCustomPermissionList = miniAppStatus.getCustomPermissions(forMiniApp: "123")
                    expect(miniAppCustomPermissionList?[0].permissionName.rawValue).toEventually(equal("rakuten.miniapp.user.USER_NAME"))
                    expect(miniAppCustomPermissionList?[0].isPermissionGranted.rawValue).toEventually(equal("ALLOWED"))
                    expect(miniAppCustomPermissionList?[1].permissionName.rawValue).toEventually(equal("rakuten.miniapp.user.PROFILE_PHOTO"))
                    expect(miniAppCustomPermissionList?[1].isPermissionGranted.rawValue).toEventually(equal("DENIED"))
                    profilePhotoPermission.isPermissionGranted = .allowed
                    miniAppStatus.setCustomPermissions(forMiniApp: "123", permissionList: [profilePhotoPermission])
                    miniAppCustomPermissionList = miniAppStatus.getCustomPermissions(forMiniApp: "123")
                    expect(miniAppCustomPermissionList?[1].isPermissionGranted.rawValue).toEventually(equal("ALLOWED"))
                    UserDefaults().removePersistentDomain(forName: "com.rakuten.tech.mobile.miniapp.MiniAppDemo.MiniAppInfo")

                }
            }
        }
    }
}
