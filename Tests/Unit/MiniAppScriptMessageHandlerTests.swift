import Quick
import Nimble
import WebKit
@testable import MiniApp

// swiftlint:disable function_body_length
// swiftlint:disable file_length
// swiftlint:disable type_body_length
class MiniAppScriptMessageHandlerTests: QuickSpec {

    override func spec() {
        describe("Mini App Script message handler test") {
            let callbackProtocol = MockMiniAppCallbackProtocol()
            let mockMessageInterface = MockMessageInterface()

            let scriptMessageHandler = MiniAppScriptMessageHandler(
                delegate: callbackProtocol,
                hostAppMessageDelegate: mockMessageInterface,
                miniAppId: "Test", miniAppTitle: "Mini App"
            )
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
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: callbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        miniAppId: "Test", miniAppTitle: "Mini App"
                    )
                    let mockMessage = MockWKScriptMessage(name: "", body: "{\"action\": \"getUniqueId\", \"param\": { \"permission\": null}, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.messageId).toEventually(equal("12345"))
                    expect(callbackProtocol.errorMessage).toEventually(contain(MiniAppJavaScriptError.internalError.rawValue))
                    expect(callbackProtocol.errorMessage).toEventually(contain(MiniAppJavaScriptError.internalError.description))
                }
            }
            context("when handleBridgeMessage receive invalid action, valid id") {
                it("will return error") {
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: callbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        miniAppId: "Test", miniAppTitle: "Mini App"
                    )
                    let requestParam = RequestParameters(action: "", permission: "location", permissions: nil, locationOptions: nil, shareInfo: ShareInfoParameters(content: ""))
                    let javascriptMessageInfo = MiniAppJavaScriptMessageInfo(action: "", id: "123", param: requestParam)
                    scriptMessageHandler.handleBridgeMessage(responseJson: javascriptMessageInfo)
                    expect(callbackProtocol.errorMessage).toEventually(contain(MiniAppJavaScriptError.unexpectedMessageFormat.rawValue))
                }
            }
            context("when handleBridgeMessage receive valid action, invalid id") {
                it("will return error") {
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: callbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        miniAppId: "Test", miniAppTitle: "Mini App"
                    )
                    let requestParam = RequestParameters(action: "", permission: "location", permissions: nil, locationOptions: nil, shareInfo: ShareInfoParameters(content: ""))
                    let javascriptMessageInfo = MiniAppJavaScriptMessageInfo(action: "getUniqueId", id: "", param: requestParam)
                    scriptMessageHandler.handleBridgeMessage(responseJson: javascriptMessageInfo)
                    expect(callbackProtocol.errorMessage).toEventually(contain(MiniAppJavaScriptError.unexpectedMessageFormat.rawValue))
                }
            }
            context("when handleActionCommand receive valid action, but failed to retrieve unique id") {
                it("will return error") {
                    mockMessageInterface.mockUniqueId = true
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: callbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        miniAppId: "Test", miniAppTitle: "Mini App"
                    )
                    scriptMessageHandler.sendUniqueId(messageId: "1234")
                    expect(callbackProtocol.errorMessage).toEventually(contain(MiniAppJavaScriptError.internalError.rawValue))
                    expect(callbackProtocol.errorMessage).toEventually(contain(MiniAppJavaScriptError.internalError.description))
                }
            }
            context("when MiniAppScriptMessageHandler receives valid requestPermission command and request parameter, but user didn't allow the location custom permission") {
                 it("will return error") {
                     let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: callbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        miniAppId: "Test", miniAppTitle: "Mini App"
                    )
                    mockMessageInterface.locationAllowed = true
                    let mockMessage = MockWKScriptMessage(name: "", body: "{\"action\": \"requestPermission\", \"param\": { \"permission\": \"location\"}, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.errorMessage).toEventually(contain(MASDKPermissionError.denied.rawValue))
                 }
            }
            context("when MiniAppScriptMessageHandler receives valid requestPermission command and request parameter, but user denied the permission") {
                 it("will return denied") {
                     let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: callbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        miniAppId: "Test", miniAppTitle: "Mini App"
                    )
                    mockMessageInterface.locationAllowed = false
                    let mockMessage = MockWKScriptMessage(name: "", body: "{\"action\": \"requestPermission\", \"param\": { \"permission\": \"location\"}, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.errorMessage).toEventually(contain("NOT_DETERMINED") || contain( "DENIED"))
                 }
            }
            context("when MiniAppScriptMessageHandler receives valid requestPermission command and request parameter, but user skipped the permission") {
                 it("will return NotDetermined") {
                     let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: callbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        miniAppId: "Test", miniAppTitle: "Mini App"
                    )
                    mockMessageInterface.locationAllowed = false
                    mockMessageInterface.permissionError = .notDetermined
                    let mockMessage = MockWKScriptMessage(name: "", body: "{\"action\": \"requestPermission\", \"param\": { \"permission\": \"location\"}, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.errorMessage).toEventually(contain(MASDKPermissionError.denied.rawValue))
                 }
            }
            context("when MiniAppScriptMessageHandler receives valid requestPermission command and invalid permission type") {
                 it("will return invalidPermissionType error") {
                     let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: callbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        miniAppId: "Test", miniAppTitle: "Mini App"
                    )
                    mockMessageInterface.locationAllowed = false
                    mockMessageInterface.permissionError = .notDetermined
                    let mockMessage = MockWKScriptMessage(name: "", body: "{\"action\": \"requestPermission\", \"param\": { \"permission\": \"ppp\"}, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.errorMessage).toEventually(contain(MiniAppJavaScriptError.invalidPermissionType.rawValue))
                 }
            }
            context("when MiniAppScriptMessageHandler receives valid requestPermission command and permission type is null") {
                 it("will return invalidPermissionType error") {
                     let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: callbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        miniAppId: "Test", miniAppTitle: "Mini App"
                    )
                    mockMessageInterface.locationAllowed = false
                    mockMessageInterface.permissionError = .notDetermined
                    let mockMessage = MockWKScriptMessage(name: "", body: "{\"action\": \"requestPermission\", \"param\": { \"permission\": null}, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.errorMessage).toEventually(contain(MiniAppJavaScriptError.invalidPermissionType.rawValue))
                 }
            }
            context("when MiniAppScriptMessageHandler receives valid getCurrentPosition command") {
                 it("will return valid latitude and longitude values") {
                     let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: callbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        miniAppId: "Test", miniAppTitle: "Mini App"
                    )
                    mockMessageInterface.locationAllowed = false
                    let mockMessage = MockWKScriptMessage(name: "", body: "{\"action\": \"getCurrentPosition\", \"param\":null, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.response).toEventually(contain("latitude"))
                 }
            }
            context("when MiniAppScriptMessageHandler receives valid getCurrentPosition command") {
                 it("will return valid latitude and longitude values") {
                     let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: callbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        miniAppId: "Test", miniAppTitle: "Mini App"
                    )
                    mockMessageInterface.locationAllowed = false
                    let mockMessage = MockWKScriptMessage(name: "", body: "{\"action\": \"getCurrentPosition\", \"param\":null, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.response).toEventually(contain("longitude"))
                 }
            }
            context("when MiniAppScriptMessageHandler receives valid custom permissions command") {
                 it("will return response with name and status for all permission that is requested") {
                     let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: callbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        miniAppId: "Test", miniAppTitle: "Mini App"
                    )
                    mockMessageInterface.customPermissions = true
                    let mockMessage = MockWKScriptMessage(
                        name: "", body: "{\"action\":\"requestCustomPermissions\",\"param\":{\"permissions\":" + "[{\"name\":\"rakuten.miniapp.user.USER_NAME\"," +
                            "\"description\":\"Description for the requesting permission\"}]},\"id\":\"1.0343410245054572\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.response).toEventuallyNot(beNil(), timeout: .seconds(10))
                    guard let responseData: Data = callbackProtocol.response?.data(using: .utf8) else {
                        return
                    }
                    let decodedObj = try JSONDecoder().decode(MiniAppCustomPermissionsResponse.self, from: responseData)
                    expect(decodedObj.permissions[0].name).toEventually(equal("rakuten.miniapp.user.USER_NAME"), timeout: .seconds(10))
                    expect(decodedObj.permissions[0].status).toEventually(equal("ALLOWED"), timeout: .seconds(10))
                 }
            }
            context("when MiniAppScriptMessageHandler receives valid custom permissions command but invalid permission object title instead of name") {
                 it("will return error response with error title and description for permission that is requested") {
                     let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: callbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        miniAppId: "Test", miniAppTitle: "Mini App"
                    )
                    mockMessageInterface.customPermissions = true
                    let mockMessage = MockWKScriptMessage(
                        name: "", body: "{\"action\":\"requestCustomPermissions\",\"param\":{\"permissions\":" + "[{\"title\":\"rakuten.miniapp.user.USER_NAME\"," +
                            "\"description\":\"Description for the requesting permission\"}]},\"id\":\"1.0343410245054572\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.errorMessage).toEventuallyNot(beNil(), timeout: .seconds(10))
                    expect(callbackProtocol.errorMessage).toEventually(contain(MASDKCustomPermissionError.invalidCustomPermissionsList.rawValue))
                 }
            }
            context("when MiniAppScriptMessageHandler receives valid custom permissions command but only one unknown custom permission") {
                 it("will return error response with error title and description for permission that is requested") {
                     let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: callbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        miniAppId: "Test", miniAppTitle: "Mini App"
                    )
                    mockMessageInterface.customPermissions = true
                    let mockMessage = MockWKScriptMessage(
                        name: "", body: "{\"action\":\"requestCustomPermissions\",\"param\":{\"permissions\":" + "[{\"name\":\"rakuten.miniapp.user.LOCATION\"," +
                            "\"description\":\"Description for the requesting permission\"}]},\"id\":\"1.0343410245054572\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.errorMessage).toEventuallyNot(beNil(), timeout: .seconds(10))
                    expect(callbackProtocol.errorMessage).toEventually(contain(MASDKCustomPermissionError.invalidCustomPermissionsList.rawValue))
                 }
            }
            context("when MiniAppScriptMessageHandler receives valid custom permissions command but  no custom permissions requested") {
                 it("will return error response with error title and description for permission that is requested") {
                     let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: callbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        miniAppId: "Test", miniAppTitle: "Mini App"
                    )
                    mockMessageInterface.customPermissions = true
                    let mockMessage = MockWKScriptMessage(
                        name: "", body: "{\"action\":\"requestCustomPermissions\",\"param\":{\"permissions\": null},\"id\":\"1.0343410245054572\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.errorMessage).toEventuallyNot(beNil(), timeout: .seconds(10))
                    expect(callbackProtocol.errorMessage).toEventually(contain(MASDKCustomPermissionError.invalidCustomPermissionRequest.rawValue))
                 }
            }
            context("when MiniAppScriptMessageHandler receives valid share info message") {
                it("will return SUCCESS after host app displays UIActivityController") {
                    mockMessageInterface.messageContentAllowed = true
                    let scriptMessageHandler = MiniAppScriptMessageHandler(delegate: callbackProtocol, hostAppMessageDelegate: mockMessageInterface, miniAppId: "Test", miniAppTitle: "Mini App")
                    let mockMessage = MockWKScriptMessage(
                        name: "", body: "{\"action\":\"shareInfo\",\"param\":{\"shareInfo\":{\"content\":\"Test Message\"}},\"id\":\"1.033890137027198\"}"as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.response).toEventuallyNot(beNil(), timeout: .seconds(10))
                    expect(callbackProtocol.response).toEventually(equal("SUCCESS"), timeout: .seconds(10))
                 }
            }
            context("when MiniAppScriptMessageHandler receives valid share info message but there is an error in host app delegate") {
                it("will return Error") {
                    mockMessageInterface.messageContentAllowed = false
                    let scriptMessageHandler = MiniAppScriptMessageHandler(delegate: callbackProtocol, hostAppMessageDelegate: mockMessageInterface, miniAppId: "Test", miniAppTitle: "Mini App")
                    let mockMessage = MockWKScriptMessage(
                        name: "", body: "{\"action\":\"shareInfo\",\"param\":{\"shareInfo\":{\"content\":\"Test Message\"}},\"id\":\"1.033890137027198\"}"as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.errorMessage).toEventually(contain("ShareContentError"), timeout: .seconds(10))
                 }
            }

            context("when MiniAppScriptMessageHandler receives valid getUsername command") {
                 it("will return User Name if User has set the Username in the User Profile") {
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    mockMessageInterface.mockUserName = "Rakuten"
                     let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: mockCallbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        miniAppId: "Test", miniAppTitle: "Mini App"
                    )
                    mockMessageInterface.messageContentAllowed = false
                    let mockMessage = MockWKScriptMessage(
                        name: "", body: "{\"action\": \"getUserName\", \"param\":null, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.response).toEventually(contain("Rakuten"), timeout: .seconds(10))
                 }
                it("will return Error if User didn't set the Username in the User Profile") {
                    mockMessageInterface.mockUserName = nil
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()

                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                       delegate: mockCallbackProtocol,
                       hostAppMessageDelegate: mockMessageInterface,
                       miniAppId: self.name, miniAppTitle: "Mini App"
                    )
                    updateCustomPermissionStatus(miniAppId: self.name, permissionType: .userName, status: .allowed)
                   let mockMessage = MockWKScriptMessage(
                       name: "", body: "{\"action\": \"getUserName\", \"param\":null, \"id\":\"12345\"}" as AnyObject)
                   scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                   expect(mockCallbackProtocol.errorMessage).toEventually(contain(MiniAppJavaScriptError.internalError.rawValue), timeout: .seconds(10))
                }
                it("will return Error if User didn't allow User Name permission") {
                    mockMessageInterface.mockUserName = ""
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()

                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                       delegate: mockCallbackProtocol,
                       hostAppMessageDelegate: mockMessageInterface,
                       miniAppId: self.name, miniAppTitle: "Mini App"
                    )
                    updateCustomPermissionStatus(miniAppId: self.name, permissionType: .userName, status: .denied)
                   let mockMessage = MockWKScriptMessage(
                       name: "", body: "{\"action\": \"getUserName\", \"param\":null, \"id\":\"12345\"}" as AnyObject)
                   scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.errorMessage).toEventually(contain(MASDKCustomPermissionError.userDenied.rawValue), timeout: .seconds(10))
                }
            }
            context("when MiniAppScriptMessageHandler receives valid getProfilePhoto command") {
                 it("will return Profile Photo if User has set the Profile photo in the User Profile") {
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    mockMessageInterface.mockProfilePhoto = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8wmD0HwAFPQInf/fUWQAAAABJRU5ErkJggg=="
                     let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: mockCallbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        miniAppId: self.name, miniAppTitle: "Mini App"
                    )
                    updateCustomPermissionStatus(miniAppId: self.name, permissionType: .profilePhoto, status: .allowed)
                    let mockMessage = MockWKScriptMessage(
                        name: "", body: "{\"action\": \"getProfilePhoto\", \"param\":null, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.response).toEventually(contain(mockMessageInterface.mockProfilePhoto ?? ""), timeout: .seconds(10))
                 }
                it("will return Error if User didn't set the Profile Photo in the User Profile") {
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                       delegate: mockCallbackProtocol,
                       hostAppMessageDelegate: mockMessageInterface,
                       miniAppId: self.name, miniAppTitle: "Mini App"
                   )
                   updateCustomPermissionStatus(miniAppId: self.name, permissionType: .profilePhoto, status: .allowed)
                    mockMessageInterface.mockProfilePhoto = ""
                   let mockMessage = MockWKScriptMessage(
                       name: "", body: "{\"action\": \"getProfilePhoto\", \"param\":null, \"id\":\"12345\"}" as AnyObject)
                   scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                   expect(mockCallbackProtocol.errorMessage).toEventually(contain(MiniAppJavaScriptError.internalError.rawValue), timeout: .seconds(10))
                }
                it("will return Error if User didn't allow Profile Photo permission") {
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                       delegate: mockCallbackProtocol,
                       hostAppMessageDelegate: mockMessageInterface,
                       miniAppId: self.name, miniAppTitle: "Mini App"
                   )
                   updateCustomPermissionStatus(miniAppId: self.name, permissionType: .profilePhoto, status: .denied)
                   let mockMessage = MockWKScriptMessage(
                       name: "", body: "{\"action\": \"getProfilePhoto\", \"param\":null, \"id\":\"12345\"}" as AnyObject)
                   scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                   expect(mockCallbackProtocol.errorMessage).toEventually(contain(MASDKCustomPermissionError.userDenied.rawValue), timeout: .seconds(10))
                }
            }
            context("when MiniAppScriptMessageHandler receives valid getAccessToken command") {
                 it("will return Access Token data info such as Token string and expiry date") {
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                     let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: mockCallbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        miniAppId: self.name, miniAppTitle: "Mini App"
                    )
                    mockMessageInterface.mockAccessToken = true
                    let mockMessage = MockWKScriptMessage(
                        name: "", body: "{\"action\": \"getAccessToken\", \"param\":null, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.response).toEventually(contain("MOCK_ACCESS_TOKEN"), timeout: .seconds(10))
                 }
            }
            context("when MiniAppScriptMessageHandler receives valid getAccessToken command but host app returns error") {
                 it("will return error") {
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                     let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: mockCallbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        miniAppId: self.name, miniAppTitle: "Mini App"
                    )
                    mockMessageInterface.mockAccessToken = false
                    let mockMessage = MockWKScriptMessage(
                        name: "", body: "{\"action\": \"getAccessToken\", \"param\":null, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.errorMessage).toEventually(contain(MASDKCustomPermissionError.unknownError.rawValue), timeout: .seconds(10))
                 }
            }
            context("when MiniAppScriptMessageHandler receives invalid orientation lock command") {
                 it("will return error") {
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: mockCallbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        miniAppId: "Test", miniAppTitle: "Mini App"
                    )
                    mockMessageInterface.messageContentAllowed = false
                    let mockMessage = MockWKScriptMessage(
                        name: "", body: "{\"action\":\"setScreenOrientation\",\"param\":{\"action\":null},\"id\":\"5.733550049709592\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.errorMessage).toEventually(contain(MiniAppJavaScriptError.unexpectedMessageFormat.rawValue), timeout: .seconds(10))
                 }
            }
            context("when MiniAppScriptMessageHandler receives no orientation lock command") {
                 it("will return error") {
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: mockCallbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        miniAppId: "Test", miniAppTitle: "Mini App"
                    )
                    mockMessageInterface.messageContentAllowed = false
                    let mockMessage = MockWKScriptMessage(
                        name: "", body: "{\"action\":\"setScreenOrientation\",\"param\":{\"action\":\"rakuten.miniapp.screen.LOCK_LANDSCAPE_RIGHT\"},\"id\":\"5.733550049709592\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.errorMessage).toEventually(contain(MiniAppJavaScriptError.unexpectedMessageFormat.rawValue), timeout: .seconds(10))
                 }
            }
        }
    }
}
