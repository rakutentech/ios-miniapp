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

            let scriptMessageHandler = MiniAppScriptMessageHandler(delegate: callbackProtocol, hostAppMessageDelegate: mockMessageInterface, miniAppId: "Test")
            afterEach {
                deleteStatusPreferences()
            }
            context("when user controller receive valid action and id") {
                it("will return unique id") {
                    mockMessageInterface.mockUniqueId = false
                    let mockMessage = MockWKScriptMessage(name: "getUniqueId", body: "{\"action\": \"getUniqueId\", \"param\": { \"permission\": null}, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.messageId).toEventually(equal("12345"))
                    expect(callbackProtocol.response).toEventuallyNot(beNil())
                }
            }
            context("when user controller receive valid action and id but failed to retrieve unique id") {
                it("will return error") {
                    mockMessageInterface.mockUniqueId = true
                    let scriptMessageHandler = MiniAppScriptMessageHandler(delegate: callbackProtocol, hostAppMessageDelegate: mockMessageInterface, miniAppId: "Test")
                    let mockMessage = MockWKScriptMessage(name: "", body: "{\"action\": \"getUniqueId\", \"param\": { \"permission\": null}, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.messageId).toEventually(equal("12345"))
                    expect(callbackProtocol.errorMessage).toEventually(equal(MiniAppJavaScriptError.internalError.rawValue))                }
            }
            context("when handleBridgeMessage receive invalid action, valid id") {
                it("will return error") {
                    let scriptMessageHandler = MiniAppScriptMessageHandler(delegate: callbackProtocol, hostAppMessageDelegate: mockMessageInterface, miniAppId: "Test")
                    let requestParam = RequestParameters(permission: "location", permissions: nil, locationOptions: nil, shareInfo: ShareInfoParameters(content: ""))
                    let javascriptMessageInfo = MiniAppJavaScriptMessageInfo(action: "", id: "123", param: requestParam)
                    scriptMessageHandler.handleBridgeMessage(responseJson: javascriptMessageInfo)
                    expect(callbackProtocol.errorMessage).toEventually(contain(MiniAppJavaScriptError.unexpectedMessageFormat.rawValue))
                }
            }
            context("when handleBridgeMessage receive valid action, invalid id") {
                it("will return error") {
                    let scriptMessageHandler = MiniAppScriptMessageHandler(delegate: callbackProtocol, hostAppMessageDelegate: mockMessageInterface, miniAppId: "Test")
                    let requestParam = RequestParameters(permission: "location", permissions: nil, locationOptions: nil, shareInfo: ShareInfoParameters(content: ""))
                    let javascriptMessageInfo = MiniAppJavaScriptMessageInfo(action: "getUniqueId", id: "", param: requestParam)
                    scriptMessageHandler.handleBridgeMessage(responseJson: javascriptMessageInfo)
                    expect(callbackProtocol.errorMessage).toEventually(contain(MiniAppJavaScriptError.unexpectedMessageFormat.rawValue))
                }
            }
            context("when handleActionCommand receive valid action, but failed to retrieve unique id") {
                it("will return error") {
                    mockMessageInterface.mockUniqueId = true
                    let scriptMessageHandler = MiniAppScriptMessageHandler(delegate: callbackProtocol, hostAppMessageDelegate: mockMessageInterface, miniAppId: "Test")
                    scriptMessageHandler.sendUniqueId(messageId: "1234")
                    expect(callbackProtocol.errorMessage).toEventually(equal(MiniAppJavaScriptError.internalError.rawValue))
                }
            }
            context("when MiniAppScriptMessageHandler receives valid requestPermission command and request parameter, but user allowed the permission") {
                 it("will return error") {
                     let scriptMessageHandler = MiniAppScriptMessageHandler(delegate: callbackProtocol, hostAppMessageDelegate: mockMessageInterface, miniAppId: "Test")
                    mockMessageInterface.locationAllowed = true
                    let mockMessage = MockWKScriptMessage(name: "", body: "{\"action\": \"requestPermission\", \"param\": { \"permission\": \"location\"}, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.response).toEventually(equal("ALLOWED"))
                 }
            }
            context("when MiniAppScriptMessageHandler receives valid requestPermission command and request parameter, but user denied the permission") {
                 it("will return denied") {
                     let scriptMessageHandler = MiniAppScriptMessageHandler(delegate: callbackProtocol, hostAppMessageDelegate: mockMessageInterface, miniAppId: "Test")
                    mockMessageInterface.locationAllowed = false
                    let mockMessage = MockWKScriptMessage(name: "", body: "{\"action\": \"requestPermission\", \"param\": { \"permission\": \"location\"}, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.errorMessage).toEventually(equal("NOT_DETERMINED") || equal( "DENIED"))
                 }
            }
            context("when MiniAppScriptMessageHandler receives valid requestPermission command and request parameter, but user skipped the permission") {
                 it("will return NotDetermined") {
                     let scriptMessageHandler = MiniAppScriptMessageHandler(delegate: callbackProtocol, hostAppMessageDelegate: mockMessageInterface, miniAppId: "Test")
                    mockMessageInterface.locationAllowed = false
                    mockMessageInterface.permissionError = .notDetermined
                    let mockMessage = MockWKScriptMessage(name: "", body: "{\"action\": \"requestPermission\", \"param\": { \"permission\": \"location\"}, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.errorMessage).toEventually(equal("NOT_DETERMINED"))
                 }
            }
            context("when MiniAppScriptMessageHandler receives valid requestPermission command and invalid permission type") {
                 it("will return invalidPermissionType error") {
                     let scriptMessageHandler = MiniAppScriptMessageHandler(delegate: callbackProtocol, hostAppMessageDelegate: mockMessageInterface, miniAppId: "Test")
                    mockMessageInterface.locationAllowed = false
                    mockMessageInterface.permissionError = .notDetermined
                    let mockMessage = MockWKScriptMessage(name: "", body: "{\"action\": \"requestPermission\", \"param\": { \"permission\": \"ppp\"}, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.errorMessage).toEventually(equal("invalidPermissionType"))
                 }
            }
            context("when MiniAppScriptMessageHandler receives valid getCurrentPosition command") {
                 it("will return valid latitude and longitude values") {
                     let scriptMessageHandler = MiniAppScriptMessageHandler(delegate: callbackProtocol, hostAppMessageDelegate: mockMessageInterface, miniAppId: "Test")
                    mockMessageInterface.locationAllowed = false
                    let mockMessage = MockWKScriptMessage(name: "", body: "{\"action\": \"getCurrentPosition\", \"param\":null, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.response).toEventually(contain("latitude"))
                 }
            }
            context("when MiniAppScriptMessageHandler receives valid getCurrentPosition command") {
                 it("will return valid latitude and longitude values") {
                     let scriptMessageHandler = MiniAppScriptMessageHandler(delegate: callbackProtocol, hostAppMessageDelegate: mockMessageInterface, miniAppId: "Test")
                    mockMessageInterface.locationAllowed = false
                    let mockMessage = MockWKScriptMessage(name: "", body: "{\"action\": \"getCurrentPosition\", \"param\":null, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.response).toEventually(contain("longitude"))
                 }
            }
            context("when MiniAppScriptMessageHandler receives valid custom permissions command") {
                 it("will return response with name and isGranted status for all permission that is requested") {
                     let scriptMessageHandler = MiniAppScriptMessageHandler(delegate: callbackProtocol, hostAppMessageDelegate: mockMessageInterface, miniAppId: "Test")
                    mockMessageInterface.customPermissions = true
                    let mockMessage = MockWKScriptMessage(
                        name: "", body: "{\"action\":\"requestCustomPermissions\",\"param\":{\"permissions\":" + "[{\"name\":\"rakuten.miniapp.user.USER_NAME\"," +
                            "\"description\":\"Description for the requesting permission\"}]},\"id\":\"1.0343410245054572\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.response).toEventuallyNot(beNil(), timeout: 10)
                    guard let responseData: Data = callbackProtocol.response?.data(using: .utf8) else {
                        return
                    }
                    let decodedObj = try JSONDecoder().decode(MiniAppCustomPermissionsResponse.self, from: responseData)
                    expect(decodedObj.permissions[0].name).toEventually(equal("rakuten.miniapp.user.USER_NAME"), timeout: 10)
                    expect(decodedObj.permissions[0].isGranted).toEventually(equal("ALLOWED"), timeout: 10)
                 }
            }
            context("when MiniAppScriptMessageHandler receives valid custom permissions command but invalid permission object title instead of name") {
                 it("will return error response with error title and description for permission that is requested") {
                     let scriptMessageHandler = MiniAppScriptMessageHandler(delegate: callbackProtocol, hostAppMessageDelegate: mockMessageInterface, miniAppId: "Test")
                    mockMessageInterface.customPermissions = true
                    let mockMessage = MockWKScriptMessage(
                        name: "", body: "{\"action\":\"requestCustomPermissions\",\"param\":{\"permissions\":" + "[{\"title\":\"rakuten.miniapp.user.USER_NAME\"," +
                            "\"description\":\"Description for the requesting permission\"}]},\"id\":\"1.0343410245054572\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.errorMessage).toEventuallyNot(beNil(), timeout: 10)
                    expect(callbackProtocol.errorMessage).toEventually(contain(MASDKCustomPermissionError.invalidCustomPermissionsList.rawValue))
                 }
            }
            context("when MiniAppScriptMessageHandler receives valid custom permissions command but only one unknown custom permission") {
                 it("will return error response with error title and description for permission that is requested") {
                     let scriptMessageHandler = MiniAppScriptMessageHandler(delegate: callbackProtocol, hostAppMessageDelegate: mockMessageInterface, miniAppId: "Test")
                    mockMessageInterface.customPermissions = true
                    let mockMessage = MockWKScriptMessage(
                        name: "", body: "{\"action\":\"requestCustomPermissions\",\"param\":{\"permissions\":" + "[{\"name\":\"rakuten.miniapp.user.LOCATION\"," +
                            "\"description\":\"Description for the requesting permission\"}]},\"id\":\"1.0343410245054572\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.errorMessage).toEventuallyNot(beNil(), timeout: 10)
                    expect(callbackProtocol.errorMessage).toEventually(contain(MASDKCustomPermissionError.invalidCustomPermissionsList.rawValue))
                 }
            }
            context("when MiniAppScriptMessageHandler receives valid custom permissions command but  no custom permissions requested") {
                 it("will return error response with error title and description for permission that is requested") {
                     let scriptMessageHandler = MiniAppScriptMessageHandler(delegate: callbackProtocol, hostAppMessageDelegate: mockMessageInterface, miniAppId: "Test")
                    mockMessageInterface.customPermissions = true
                    let mockMessage = MockWKScriptMessage(
                        name: "", body: "{\"action\":\"requestCustomPermissions\",\"param\":{\"permissions\": null},\"id\":\"1.0343410245054572\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.errorMessage).toEventuallyNot(beNil(), timeout: 10)
                    expect(callbackProtocol.errorMessage).toEventually(contain(MASDKCustomPermissionError.invalidCustomPermissionRequest.rawValue))
                 }
            }
            context("when MiniAppScriptMessageHandler receives valid share info message") {
                 it("will return SUCCESS after host app displays UIActivityController") {
                     let scriptMessageHandler = MiniAppScriptMessageHandler(delegate: callbackProtocol, hostAppMessageDelegate: mockMessageInterface, miniAppId: "Test")
                    mockMessageInterface.messageContentAllowed = true
                    let mockMessage = MockWKScriptMessage(
                        name: "", body: "{\"action\":\"shareInfo\",\"param\":{\"shareInfo\":{\"content\":\"Test Message\"}},\"id\":\"1.033890137027198\"}"as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.response).toEventuallyNot(beNil(), timeout: 10)
                    expect(callbackProtocol.response).toEventually(equal("SUCCESS"), timeout: 10)
                 }
            }
            context("when MiniAppScriptMessageHandler receives valid share info message but there is an error in host app delegate") {
                 it("will return Error") {
                     let scriptMessageHandler = MiniAppScriptMessageHandler(delegate: callbackProtocol, hostAppMessageDelegate: mockMessageInterface, miniAppId: "Test")
                    mockMessageInterface.messageContentAllowed = false
                    let mockMessage = MockWKScriptMessage(
                        name: "", body: "{\"action\":\"shareInfo\",\"param\":{\"shareInfo\":{\"content\":\"Test Message\"}},\"id\":\"1.033890137027198\"}"as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.errorMessage).toEventually(contain("ShareContentError"), timeout: 10)
                 }
            }
        }
    }
}
