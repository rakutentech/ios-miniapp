import Foundation

import Quick
import Nimble
@testable import MiniApp

// This File will be removed once the Deprecated methods are removed.
class MASDKLocaleTests: QuickSpec {
    override func spec() {
        describe("When MASDKLocale localize method is called") {
            context("with localizable key that has no params to be passed") {
                it("it will return the value of just the localizable key") {
                    expect(MASDKLocale.localize(.allow, "Test")).to(equal("Allow"))
                }
            }
        }
    }
}
