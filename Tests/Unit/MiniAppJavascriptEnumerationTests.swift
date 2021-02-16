import Quick
import Nimble
@testable import MiniApp

// swiftlint:disable function_body_length
class MiniAppJavascriptEnumerationTests: QuickSpec {

    override func spec() {
        describe("MiniApp Javascript Enumeration tests") {
            context("when MiniAppCustomPermissionType is initialized with User name custom permissions string") {
                it("will return rawValue and title") {
                    let miniAppPermissionType = MiniAppCustomPermissionType(rawValue: "rakuten.miniapp.user.USER_NAME")
                    expect(miniAppPermissionType).to(equal(MiniAppCustomPermissionType.userName))
                    expect(miniAppPermissionType?.title).to(equal("User Name"))
                }
            }
            context("when MiniAppCustomPermissionType is initialized with Profile photo custom permissions string") {
                it("will return rawValue and title") {
                    let miniAppPermissionType = MiniAppCustomPermissionType(rawValue: "rakuten.miniapp.user.PROFILE_PHOTO")
                    expect(miniAppPermissionType).to(equal(MiniAppCustomPermissionType.profilePhoto))
                    expect(miniAppPermissionType?.title).to(equal("Profile Photo"))
                }
            }
            context("when MiniAppCustomPermissionType is initialized with Contact List custom permissions string") {
                it("will return rawValue and title") {
                    let miniAppPermissionType = MiniAppCustomPermissionType(rawValue: "rakuten.miniapp.user.CONTACT_LIST")
                    expect(miniAppPermissionType).to(equal(MiniAppCustomPermissionType.contactsList))
                    expect(miniAppPermissionType?.title).to(equal("Contact List"))
                }
            }
            context("when MiniAppCustomPermissionType is initialized with Access Token custom permissions string") {
                it("will return rawValue and title") {
                    let miniAppPermissionType = MiniAppCustomPermissionType(rawValue: "rakuten.miniapp.user.ACCESS_TOKEN")
                    expect(miniAppPermissionType).to(equal(MiniAppCustomPermissionType.accessToken))
                    expect(miniAppPermissionType?.title).to(equal("Access Token"))
                }
            }
            context("when MiniAppCustomPermissionGrantedStatus is initialized with ALLOWED status") {
                it("will return true") {
                    let miniAppPermissionStatus = MiniAppCustomPermissionGrantedStatus(rawValue: "ALLOWED")
                    expect(miniAppPermissionStatus?.boolValue).to(equal(true))
                }
            }
            context("when MiniAppCustomPermissionGrantedStatus is initialized with DENIED status") {
                it("will return false") {
                    let miniAppPermissionStatus = MiniAppCustomPermissionGrantedStatus(rawValue: "DENIED")
                    expect(miniAppPermissionStatus?.boolValue).to(equal(false))
                }
            }
            context("when MiniAppInterfaceOrientation is initialized with valid Portrait string ") {
                it("will return portrait UIInterfaceOrientationMask") {
                    let miniAppInterfaceOrientation = MiniAppInterfaceOrientation(rawValue: "rakuten.miniapp.screen.LOCK_PORTRAIT")
                    expect(miniAppInterfaceOrientation).to(equal(MiniAppInterfaceOrientation.lockPortrait))
                    expect(miniAppInterfaceOrientation?.orientation).to(equal(UIInterfaceOrientationMask.portrait))
                }
            }
            context("when MiniAppInterfaceOrientation is initialized with valid Landscape string ") {
                it("will return landscape UIInterfaceOrientationMask") {
                    let miniAppInterfaceOrientation = MiniAppInterfaceOrientation(rawValue: "rakuten.miniapp.screen.LOCK_LANDSCAPE")
                    expect(miniAppInterfaceOrientation).to(equal(MiniAppInterfaceOrientation.lockLandscape))
                    expect(miniAppInterfaceOrientation?.orientation).to(equal(UIInterfaceOrientationMask.landscape))
                }
            }
            context("when MiniAppInterfaceOrientation is initialized with valid LOCK_RELEASE string") {
                it("will return all UIInterfaceOrientationMask") {
                    let miniAppInterfaceOrientation = MiniAppInterfaceOrientation(rawValue: "rakuten.miniapp.screen.LOCK_RELEASE")
                    expect(miniAppInterfaceOrientation).to(equal(MiniAppInterfaceOrientation.lockRelease))
                    expect(miniAppInterfaceOrientation?.orientation).to(equal([]))
                }
            }
        }
    }
}
