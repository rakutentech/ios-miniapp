import Foundation

import Quick
import Nimble
@testable import MiniApp

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
        }
    }
}
