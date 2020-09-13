import Quick
import Nimble
@testable import MiniApp

class MiniAppKeyChainTests: QuickSpec {

    override func spec() {
        describe("Mini App Key chain tests") {
            context("when setDefaultPermissionsInKeyChain is called") {
                it("will return all default permissions with denied status ") {
                    let miniAppKeyStore = MiniAppKeyChain()
                    let allPermissions = miniAppKeyStore.setDefaultPermissionsInKeyChain(forMiniApp: "123", allKeys: ["Test": []])
                    expect(allPermissions.count).toEventually(equal(MiniAppCustomPermissionType.allCases.count))
                }
            }
        }
    }
}
