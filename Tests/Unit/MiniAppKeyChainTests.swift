import Quick
import Nimble
@testable import MiniApp

class MiniAppKeyChainTests: QuickSpec {

    override func spec() {
        describe("Mini App Key chain tests") {
            context("when storeCustomPermissions method is called with valid params") {
                it("will store the value in Keychain") {
                    let miniAppKeyStore = MiniAppKeyChain()
                    let customPermissions = miniAppKeyStore.getDefaultSupportedPermissions()
                    _ = customPermissions.map { return $0.isPermissionGranted = .allowed }
                    miniAppKeyStore.storeCustomPermissions(permissions: customPermissions, forMiniApp: mockMiniAppInfo.id)
                    let retrievedPermission = miniAppKeyStore.getCustomPermissions(forMiniApp: mockMiniAppInfo.id)
                    print("")
                    for (permission) in retrievedPermission {
                        expect(permission.isPermissionGranted).toEventually(equal(MiniAppCustomPermissionGrantedStatus.allowed))
                    }
                    miniAppKeyStore.removeKey(for: mockMiniAppInfo.id)
                }
            }
        }
    }
}
