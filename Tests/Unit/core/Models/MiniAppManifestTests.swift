import Quick
import Nimble
@testable import MiniApp

class MiniAppManifestTests: QuickSpec {
    override func spec() {
        context("when MetaDataCustomPermissionModel is compared") {
            it("will comapre if both hash are equal and returns the bool") {
                let metaDataCustomPermissionModel = MetaDataCustomPermissionModel(reqPermissions: [MACustomPermissionsResponse(name: "Test", reason: "Test"),
                                                                                                   MACustomPermissionsResponse(name: "Sample", reason: "Sample")],
                                                                                  optPermissions: [], customMetaData: nil, accessTokenPermissions: nil)
                let copyMetaDataCustomPermissionModel = MetaDataCustomPermissionModel(reqPermissions: [MACustomPermissionsResponse(name: "Test", reason: "Test"),
                                                                                                    MACustomPermissionsResponse(name: "Sample", reason: "Sample")],
                                                                                   optPermissions: [], customMetaData: nil, accessTokenPermissions: nil)
                expect(metaDataCustomPermissionModel == copyMetaDataCustomPermissionModel).to(equal(true))
            }
        }
        context("when CachedMetaData is compared") {
            let cachedMetaData = CachedMetaData(version: "123", miniAppManifest: mockMiniAppManifest, hash: 1)
            let copyCachedMetaData = CachedMetaData(version: "123", miniAppManifest: mockMiniAppManifest, hash: 1)
            it("will comapre if both hash & other values are equal and returns the bool") {
                expect(cachedMetaData == copyCachedMetaData).to(equal(true))
            }
            let newCachedMetaData = CachedMetaData(version: "456", miniAppManifest: mockMiniAppManifest, hash: 1)
            it("will comapre if both hash & other values are equal and returns the bool") {
                expect(cachedMetaData == newCachedMetaData).to(equal(false))
            }
        }
    }
}
