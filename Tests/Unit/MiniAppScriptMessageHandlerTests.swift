import Quick
import Nimble
import WebKit
@testable import MiniApp

// swiftlint:disable function_body_length
class MiniAppScriptMessageHandlerTests: QuickSpec {

    override func spec() {
        describe("Mini App Script message handler test") {
            let callbackProtocol = MockMiniAppCallbackProtocol()
            let mockMessageInterface = MockMessageInterface()

            let scriptMessageHandler = MiniAppScriptMessageHandler(delegate: callbackProtocol, hostAppMessageDelegate: mockMessageInterface)
            context("when user controller receive valid action and id") {
                it("will return unique id") {
                    mockMessageInterface.mockUniqueId = false
                    let mockMessage = MockWKScriptMessage(name: "getUniqueId", body: "{\"action\": \"getUniqueId\", \"param\": { \"permission\": \"location\"}, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.messageId).toEventually(equal("12345"))
                    expect(callbackProtocol.response).toEventuallyNot(beNil())
                }
            }
            context("when user controller receive valid action and id but failed to retrieve unique id") {
                it("will return error") {
                    mockMessageInterface.mockUniqueId = true
                    let scriptMessageHandler = MiniAppScriptMessageHandler(delegate: callbackProtocol, hostAppMessageDelegate: mockMessageInterface)
                    let mockMessage = MockWKScriptMessage(name: "", body: "{\"action\": \"getUniqueId\", \"param\": { \"permission\": \"location\"}, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.messageId).toEventually(equal("12345"))
                    expect(callbackProtocol.errorMessage).toEventually(equal(MiniAppJavaScriptError.internalError.rawValue))                }
            }
            context("when handleBridgeMessage receive invalid action, valid id") {
                it("will return error") {
                    let scriptMessageHandler = MiniAppScriptMessageHandler(delegate: callbackProtocol, hostAppMessageDelegate: mockMessageInterface)
                    let requestParam = RequestParameters(permission: "location")
                    let javascriptMessageInfo = MiniAppJavaScriptMessageInfo(action: "", id: "123", param: requestParam)
                    scriptMessageHandler.handleBridgeMessage(responseJson: javascriptMessageInfo)
                    expect(callbackProtocol.errorMessage).toEventually(equal(MiniAppJavaScriptError.unexpectedMessageFormat.rawValue))
                }
            }
            context("when handleBridgeMessage receive valid action, invalid id") {
                it("will return error") {
                    let scriptMessageHandler = MiniAppScriptMessageHandler(delegate: callbackProtocol, hostAppMessageDelegate: mockMessageInterface)
                    let requestParam = RequestParameters(permission: "location")
                    let javascriptMessageInfo = MiniAppJavaScriptMessageInfo(action: "getUniqueId", id: "", param: requestParam)
                    scriptMessageHandler.handleBridgeMessage(responseJson: javascriptMessageInfo)
                    expect(callbackProtocol.errorMessage).toEventually(equal(MiniAppJavaScriptError.unexpectedMessageFormat.rawValue))
                }
            }
            context("when handleActionCommand receive valid action, but failed to retrieve unique id") {
                it("will return error") {
                    mockMessageInterface.mockUniqueId = true
                    let scriptMessageHandler = MiniAppScriptMessageHandler(delegate: callbackProtocol, hostAppMessageDelegate: mockMessageInterface)
                    scriptMessageHandler.sendUniqueId(messageId: "1234")
                    expect(callbackProtocol.errorMessage).toEventually(equal(MiniAppJavaScriptError.internalError.rawValue))
                }
            }
            context("when MiniAppScriptMessageHandler receives valid requestPermission command and request parameter, but user allowed the permission") {
                 it("will return error") {
                     let scriptMessageHandler = MiniAppScriptMessageHandler(delegate: callbackProtocol, hostAppMessageDelegate: mockMessageInterface)
                    mockMessageInterface.locationAllowed = true
                    let mockMessage = MockWKScriptMessage(name: "", body: "{\"action\": \"requestPermission\", \"param\": { \"permission\": \"location\"}, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.response).toEventually(equal("Allowed"))
                 }
            }
            context("when MiniAppScriptMessageHandler receives valid requestPermission command and request parameter, but user denied the permission") {
                 it("will return denied") {
                     let scriptMessageHandler = MiniAppScriptMessageHandler(delegate: callbackProtocol, hostAppMessageDelegate: mockMessageInterface)
                    mockMessageInterface.locationAllowed = false
                    let mockMessage = MockWKScriptMessage(name: "", body: "{\"action\": \"requestPermission\", \"param\": { \"permission\": \"location\"}, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.errorMessage).toEventually(equal("Denied") || equal("NotDetermined"))
                 }
            }
            context("when MiniAppScriptMessageHandler receives valid requestPermission command and request parameter, but user skipped the permission") {
                 it("will return NotDetermined") {
                     let scriptMessageHandler = MiniAppScriptMessageHandler(delegate: callbackProtocol, hostAppMessageDelegate: mockMessageInterface)
                    mockMessageInterface.locationAllowed = false
                    mockMessageInterface.permissionError = MiniAppPermissionResult.notDetermined
                    let mockMessage = MockWKScriptMessage(name: "", body: "{\"action\": \"requestPermission\", \"param\": { \"permission\": \"location\"}, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.errorMessage).toEventually(equal("NotDetermined"))
                 }
            }
            context("when MiniAppScriptMessageHandler receives valid requestPermission command and invalid permission type") {
                 it("will return invalidPermissionType error") {
                     let scriptMessageHandler = MiniAppScriptMessageHandler(delegate: callbackProtocol, hostAppMessageDelegate: mockMessageInterface)
                    mockMessageInterface.locationAllowed = false
                    mockMessageInterface.permissionError = MiniAppPermissionResult.notDetermined
                    let mockMessage = MockWKScriptMessage(name: "", body: "{\"action\": \"requestPermission\", \"param\": { \"permission\": \"ppp\"}, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.errorMessage).toEventually(equal("invalidPermissionType"))
                 }
            }
            context("when MiniAppScriptMessageHandler receives valid getCurrentPosition command") {
                 it("will return valid latitude and longitude values") {
                     let scriptMessageHandler = MiniAppScriptMessageHandler(delegate: callbackProtocol, hostAppMessageDelegate: mockMessageInterface)
                    mockMessageInterface.locationAllowed = false
                    let mockMessage = MockWKScriptMessage(name: "", body: "{\"action\": \"getCurrentPosition\", \"param\":null, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.response).toEventually(contain("latitude"))
                 }
            }
            context("when MiniAppScriptMessageHandler receives valid getCurrentPosition command") {
                 it("will return valid latitude and longitude values") {
                     let scriptMessageHandler = MiniAppScriptMessageHandler(delegate: callbackProtocol, hostAppMessageDelegate: mockMessageInterface)
                    mockMessageInterface.locationAllowed = false
                    let mockMessage = MockWKScriptMessage(name: "", body: "{\"action\": \"getCurrentPosition\", \"param\":null, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.response).toEventually(contain("longitude"))
                 }
            }
        }
    }
}
