import Foundation

import Quick
import Nimble
@testable import MiniApp

// swiftlint:disable function_body_length
class MessageInterfaceExtensionTests: QuickSpec {
    override func spec() {
        let mockMessageInterfaceExtension = MockMessageInterfaceExtension()
        describe("When Message Interface class interfaces are not implemented in the conformed class") {
            context("and when getContacts interface method is called") {
                it("it will return the default implementation value") {
                    expect(mockMessageInterfaceExtension.getContacts()).to(beNil())
                }
            }
            context("and when getUserName interface method is called") {
                it("it will return the default implementation value") {
                    var username: String? = "failed"
                    mockMessageInterfaceExtension.getUserName { result in
                        switch result {
                        case .success(let name):
                            username = name
                        case .failure:
                            username = nil
                        }
                    }
                    expect(username).toEventually(beNil())
                }
            }
            context("and when getProfilePhoto interface method is called") {
                it("it will return the default implementation value") {
                    var profilePhoto: String? = "failed"
                    mockMessageInterfaceExtension.getProfilePhoto { result in
                        switch result {
                        case .success(let photo):
                            profilePhoto = photo
                        case .failure:
                            profilePhoto = nil
                        }
                    }
                    expect(profilePhoto).toEventually(beNil())
                }
            }
            context("and when deprecated getAccessToken interface method is called") {
                it("it will return the default implementation value i.e failedToConformToProtocol") {
                    var errorInfo: MASDKCustomPermissionError?
                    mockMessageInterfaceExtension.getAccessToken(miniAppId: "") { result in
                        switch result {
                        case .success: break
                        case .failure(let error):
                            errorInfo = error
                        }
                    }
                    expect(errorInfo).toEventually(equal(MASDKCustomPermissionError.failedToConformToProtocol))
                }
            }
            context("and when getAccessToken interface method is called") {
                it("it will return the default implementation value i.e failedToConformToProtocol") {
                    var errorInfo: MASDKAccessTokenError?
                    mockMessageInterfaceExtension.getAccessToken(miniAppId: "", scopes: MASDKAccessTokenScopes(audience: "", scopes: [])!) { result in
                        switch result {
                        case .success: break
                        case .failure(let error):
                            errorInfo = error
                        }
                    }
                    expect(errorInfo?.description).toEventually(equal(MASDKAccessTokenError.failedToConformToProtocol.description))
                }
            }
            context("and when getPoints interface method is called") {
                it("it will return the default implementation value i.e failedToConformToProtocol") {
                    var errorInfo: MASDKPointError?
                    mockMessageInterfaceExtension.getPoints { result in
                        switch result {
                        case .success: break
                        case .failure(let error):
                            errorInfo = error
                        }
                    }
                    expect(errorInfo?.description).toEventually(equal(MASDKPointError.failedToConformToProtocol.description))
                }
            }
            context("and when getPoints interface method is called") {
                it("it will return the Points value") {
                    var points: MAPoints?
                    let mockMessageInterface = MockMessageInterface()
                    mockMessageInterface.mockPointsInterface = true
                    mockMessageInterface.getPoints { result in
                        switch result {
                        case .success(let pointsInfo):
                            points = pointsInfo
                        case .failure: break
                        }
                    }
                    expect(points?.standard).to(equal(10))
                    expect(points?.term).to(equal(10))
                    expect(points?.cash).to(equal(10))
                }
            }
        }
    }
}
