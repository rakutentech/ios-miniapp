import Quick
import Nimble
@testable import MiniApp

// swiftlint:disable function_body_length
class MiniAppStatusTests: QuickSpec {

    override func spec() {
        let miniAppKeyStore = MiniAppPermissionsStorage()

        afterEach {
            deleteStatusPreferences()
            miniAppKeyStore.removeKey(for: mockMiniAppInfo.id)
            UserDefaults().removePersistentDomain(forName: "com.rakuten.tech.mobile.miniapp.MiniAppDemo.MiniAppInfo")
        }
        describe("mini app preferences") {
            context("when setDownloadStatus is called") {
                it("will set status true value for given key") {
                    let miniAppStatus = MiniAppStatus()
                    miniAppStatus.setDownloadStatus(true, for: "mini-app/testing")
                    expect(true).to(equal(miniAppStatus.isDownloaded(key: "mini-app/testing")))
                    UserDefaults().removePersistentDomain(forName: "com.rakuten.tech.mobile.miniapp")
                }
                it("will set status false value for given key") {
                    let miniAppStatus = MiniAppStatus()
                    miniAppStatus.setDownloadStatus(false, for: "mini-app/testing")
                    expect(false).to(equal(miniAppStatus.isDownloaded(key: "mini-app/testing")))
                    UserDefaults().removePersistentDomain(forName: "com.rakuten.tech.mobile.miniapp")
                }
                it("will set status true for given appId and versionId") {
                    let miniAppStatus = MiniAppStatus()
                    miniAppStatus.setDownloadStatus(true, appId: "mini-app", versionId: "testing")
                    expect(true).to(equal(miniAppStatus.isDownloaded(appId: "mini-app", versionId: "testing")))
                    UserDefaults().removePersistentDomain(forName: "com.rakuten.tech.mobile.miniapp")
                }
                it("will set status false for given appId and versionId") {
                    let miniAppStatus = MiniAppStatus()
                    miniAppStatus.setDownloadStatus(false, appId: "mini-app", versionId: "testing")
                    expect(false).to(equal(miniAppStatus.isDownloaded(appId: "mini-app", versionId: "testing")))
                    UserDefaults().removePersistentDomain(forName: "com.rakuten.tech.mobile.miniapp")
                }
            }
            context("when unknown key is used") {
                it("will return false") {
                    let miniAppStatus = MiniAppStatus()
                    expect(false).to(equal(miniAppStatus.isDownloaded(key: "Test")))
                    UserDefaults().removePersistentDomain(forName: "com.rakuten.tech.mobile.miniapp")
                }
            }
            context("when mini app info is saved") {
                it("will return the miniapp info for a valid mini app id") {
                    let miniAppStatus = MiniAppStatus()
                    miniAppStatus.saveMiniAppInfo(appInfo: mockMiniAppInfo, key: mockMiniAppInfo.id)
                    let retrievedMiniAppInfo = miniAppStatus.getMiniAppInfo(appId: mockMiniAppInfo.id)
                    expect(retrievedMiniAppInfo?.id).to(equal(mockMiniAppInfo.id))
                    expect(retrievedMiniAppInfo?.version.versionId).to(equal(mockMiniAppInfo.version.versionId))
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
                    let miniAppKeyStore = MiniAppPermissionsStorage()
                    let userNamePermission = MASDKCustomPermissionModel(
                        permissionName: MiniAppCustomPermissionType(rawValue: MiniAppCustomPermissionType.userName.rawValue)!)
                    let profilePhotoPermission = MASDKCustomPermissionModel(
                        permissionName: MiniAppCustomPermissionType(rawValue: MiniAppCustomPermissionType.profilePhoto.rawValue)!, isPermissionGranted: MiniAppCustomPermissionGrantedStatus.denied)
                    let contactListPermission = MASDKCustomPermissionModel(
                    permissionName: MiniAppCustomPermissionType(rawValue: MiniAppCustomPermissionType.contactsList.rawValue)!, isPermissionGranted: MiniAppCustomPermissionGrantedStatus.denied)
                    let accessTokenPermission = MASDKCustomPermissionModel(
                    permissionName: MiniAppCustomPermissionType(rawValue: MiniAppCustomPermissionType.accessToken.rawValue)!, isPermissionGranted: MiniAppCustomPermissionGrantedStatus.denied)
                    miniAppKeyStore.storeCustomPermissions(permissions: [userNamePermission, profilePhotoPermission, contactListPermission, accessTokenPermission], forMiniApp: "123")
                    var miniAppCustomPermissionList = miniAppKeyStore.getCustomPermissions(forMiniApp: "123")
                    if miniAppCustomPermissionList.count >= 3 {
                        expect(miniAppCustomPermissionList[0].permissionName.rawValue).to(equal("rakuten.miniapp.user.USER_NAME"))
                        expect(miniAppCustomPermissionList[0].isPermissionGranted.rawValue).to(equal("ALLOWED"))
                        expect(miniAppCustomPermissionList[1].permissionName.rawValue).to(equal("rakuten.miniapp.user.PROFILE_PHOTO"))
                        expect(miniAppCustomPermissionList[1].isPermissionGranted.rawValue).to(equal("DENIED"))
                        expect(miniAppCustomPermissionList[2].isPermissionGranted.rawValue).to(equal("DENIED"))
                        expect(miniAppCustomPermissionList[3].permissionName.rawValue).to(equal("rakuten.miniapp.user.ACCESS_TOKEN"))
                        profilePhotoPermission.isPermissionGranted = .allowed
                        miniAppKeyStore.storeCustomPermissions(permissions: [profilePhotoPermission], forMiniApp: "123")
                        miniAppCustomPermissionList = miniAppKeyStore.getCustomPermissions(forMiniApp: "123")
                        expect(miniAppCustomPermissionList[0].isPermissionGranted.rawValue).to(equal("ALLOWED"))
                    } else {
                        fail("Failed to store and retrieve custom permissions in KeyChain")
                    }

                    UserDefaults().removePersistentDomain(forName: "com.rakuten.tech.mobile.miniapp.MiniAppDemo.MiniAppInfo")
                }
            }
            context("when checkStoredPermissionList is called with downloaded mini apps list") {
                it("will return list of custom permissions if it is stored already") {
                    let miniAppKeyStore = MiniAppPermissionsStorage()
                    let miniAppStatus = MiniAppStatus()
                    miniAppKeyStore.storeCustomPermissions(permissions: getDefaultSupportedPermissions(), forMiniApp: mockMiniAppInfo.id)
                    let miniAppCustomPermissionList = miniAppStatus.checkStoredPermissionList(downloadedMiniAppsList: [mockMiniAppInfo])
                    expect(miniAppCustomPermissionList.keys).to(contain(mockMiniAppInfo.id))
                    let miniAppInfo = MiniAppInfo(id: "123", displayName: "Test", icon: URL(string: "\(mockHost)/icon.png")!, version: mockMiniAppInfo.version)
                    let customPermissionsList = miniAppStatus.checkStoredPermissionList(downloadedMiniAppsList: [miniAppInfo])
                    expect(customPermissionsList.keys).notTo(contain(miniAppInfo.id))
                    expect(customPermissionsList.keys).notTo(contain(mockMiniAppInfo.id))
                    UserDefaults().removePersistentDomain(forName: "com.rakuten.tech.mobile.miniapp.MiniAppDemo.MiniAppInfo")
                }
            }
            context("when checkStoredPermissionList is called with downloaded mini apps list") {
                it("will return list of custom permissions if it is stored already") {
                    let miniAppStatus = MiniAppStatus()
                    miniAppStatus.saveMiniAppInfo(appInfo: mockMiniAppInfo, key: mockMiniAppInfo.id)
                    miniAppStatus.setDownloadStatus(true, appId: mockMiniAppInfo.id, versionId: mockMiniAppInfo.version.versionId)
                    let customPermissionsList = [MASDKCustomPermissionModel(
                                                    permissionName: .userName,
                                                    isPermissionGranted: .allowed,
                                                    permissionRequestDescription: ""),
                                                 MASDKCustomPermissionModel(
                                                    permissionName: .profilePhoto,
                                                    isPermissionGranted: .allowed,
                                                    permissionRequestDescription: "")]
                    miniAppKeyStore.storeCustomPermissions(permissions: customPermissionsList, forMiniApp: mockMiniAppInfo.id)
                    guard let downloadedMiniApps = miniAppStatus.getMiniAppsListWithCustomPermissionsInfo() else {
                        fail("No downloaded Mini apps found")
                        return
                    }
                    expect(downloadedMiniApps.count).notTo(equal(0))
                    if downloadedMiniApps.indices.contains(0) {
                        let miniAppInfoPair = downloadedMiniApps[0]
                        expect(miniAppInfoPair.1.count).to(equal(2))
                    }
                }
            }
        }
    }
}
