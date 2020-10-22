import Quick
import Nimble
@testable import MiniApp

class MiniAppJavascriptEnumerationTests: QuickSpec {

    override func spec() {
        describe("MiniApp Javascript Enumeration tests") {
            context("when MiniAppCustomPermissionType is initialized with User name custom permissions string") {
                it("will return rawValue and title") {
                    let miniAppPermissionType = MiniAppCustomPermissionType(rawValue: "rakuten.miniapp.user.USER_NAME")
                    expect(miniAppPermissionType).toEventually(equal(MiniAppCustomPermissionType.userName))
                    expect(miniAppPermissionType?.title).toEventually(equal("User Name"))
                }
            }
            context("when MiniAppCustomPermissionType is initialized with Profile photo custom permissions string") {
                it("will return rawValue and title") {
                    let miniAppPermissionType = MiniAppCustomPermissionType(rawValue: "rakuten.miniapp.user.PROFILE_PHOTO")
                    expect(miniAppPermissionType).toEventually(equal(MiniAppCustomPermissionType.profilePhoto))
                    expect(miniAppPermissionType?.title).toEventually(equal("Profile Photo"))
                }
            }
            context("when MiniAppCustomPermissionType is initialized with Contact List custom permissions string") {
                it("will return rawValue and title") {
                    let miniAppPermissionType = MiniAppCustomPermissionType(rawValue: "rakuten.miniapp.user.CONTACT_LIST")
                    expect(miniAppPermissionType).toEventually(equal(MiniAppCustomPermissionType.contactsList))
                    expect(miniAppPermissionType?.title).toEventually(equal("Contact List"))
                }
            }
            context("when MiniAppCustomPermissionGrantedStatus is initialized with ALLOWED status") {
                it("will return true") {
                    let miniAppPermissionStatus = MiniAppCustomPermissionGrantedStatus(rawValue: "ALLOWED")
                    expect(miniAppPermissionStatus?.boolValue).toEventually(equal(true))
                }
            }
            context("when MiniAppCustomPermissionGrantedStatus is initialized with DENIED status") {
                it("will return false") {
                    let miniAppPermissionStatus = MiniAppCustomPermissionGrantedStatus(rawValue: "DENIED")
                    expect(miniAppPermissionStatus?.boolValue).toEventually(equal(false))
                }
            }
            context("when MiniAppInterfaceOrientation is initialized with valid Portrait string ") {
                it("will return portrait UIInterfaceOrientationMask") {
                    let miniAppInterfaceOrientation = MiniAppInterfaceOrientation(rawValue: "rakuten.miniapp.screen.LOCK_PORTRAIT")
                    expect(miniAppInterfaceOrientation).toEventually(equal(MiniAppInterfaceOrientation.lockPortrait))
                    expect(miniAppInterfaceOrientation?.orientation).toEventually(equal(UIInterfaceOrientationMask.portrait))
                }
            }
            context("when MiniAppInterfaceOrientation is initialized with valid Landscape string ") {
                it("will return landscape UIInterfaceOrientationMask") {
                    let miniAppInterfaceOrientation = MiniAppInterfaceOrientation(rawValue: "rakuten.miniapp.screen.LOCK_LANDSCAPE")
                    expect(miniAppInterfaceOrientation).toEventually(equal(MiniAppInterfaceOrientation.lockLandscape))
                    expect(miniAppInterfaceOrientation?.orientation).toEventually(equal(UIInterfaceOrientationMask.landscape))
                }
            }
            context("when MiniAppInterfaceOrientation is initialized with valid LOCK_RELEASE string") {
                it("will return all UIInterfaceOrientationMask") {
                    let miniAppInterfaceOrientation = MiniAppInterfaceOrientation(rawValue: "rakuten.miniapp.screen.LOCK_RELEASE")
                    expect(miniAppInterfaceOrientation).toEventually(equal(MiniAppInterfaceOrientation.lockRelease))
                    expect(miniAppInterfaceOrientation?.orientation).toEventually(equal(UIInterfaceOrientationMask.all))
                }
            }
        }
    }
}
