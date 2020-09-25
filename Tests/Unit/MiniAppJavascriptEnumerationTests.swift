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
        }
    }
}
