import Quick
import Nimble
import WebKit
import CoreLocation
@testable import MiniApp

// swiftlint:disable function_body_length
// swiftlint:disable file_length
// swiftlint:disable type_body_length
class MiniAppScriptMessageHandlerTests: QuickSpec {

    override func spec() {
        describe("Mini App Script message handler test") {
            let callbackProtocol = MockMiniAppCallbackProtocol()
            let mockMessageInterface = MockMessageInterface()
            let mockAdsDelegate =  MockAdsDisplayer()
            let mockSecureStorageDelegate =  MockMiniAppSecureStorage()
            let mockMiniAppManageInterface = MockManageDelegateInterface()
            let mockMiniAppTitle = "Mini App"

            let scriptMessageHandler = MiniAppScriptMessageHandler(
                delegate: callbackProtocol,
                hostAppMessageDelegate: mockMessageInterface,
                adsDisplayer: mockAdsDelegate,
                secureStorageDelegate: mockSecureStorageDelegate,
                miniAppManageDelegate: mockMiniAppManageInterface,
                miniAppId: mockMiniAppInfo.id, miniAppTitle: mockMiniAppTitle
            )
            beforeEach {
                callbackProtocol.customEvent = nil
                callbackProtocol.eventMessage = nil
                callbackProtocol.messageId = nil
                callbackProtocol.errorMessage = nil
                deleteStatusPreferences()
                clearCustomPermissionsFromStorage(miniAppId: mockMiniAppInfo.id)
            }

            context("when user controller receive valid action and id") {
                it("will return unique id") {
                    let mockMessage = MockWKScriptMessage(name: "getUniqueId", body: "{\"action\": \"getUniqueId\", \"param\": { \"permission\": null}, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.messageId).toEventually(equal("12345"))
                    expect(callbackProtocol.response).toEventuallyNot(beNil())
                }
            }

            context("when user controller receive valid action and id (messaging unique id)") {
                it("will return unique id") {
                    let mockMessage = MockWKScriptMessage(
                        name: "getMessagingUniqueId",
                        body: "{\"action\": \"getMessagingUniqueId\", \"param\": { \"permission\": null}, \"id\":\"12345\"}" as AnyObject
                    )
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.messageId).toEventually(equal("12345"))
                    expect(callbackProtocol.response).toEventuallyNot(beNil())
                }
            }

            context("when user controller receive valid action and id (mauid)") {
                it("will return unique id") {
                    let mockMessage = MockWKScriptMessage(name: "getMauid", body: "{\"action\": \"getMauid\", \"param\": { \"permission\": null}, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.messageId).toEventually(equal("12345"))
                    expect(callbackProtocol.response).toEventuallyNot(beNil())
                }
            }

            context("when handleBridgeMessage receive invalid action, valid id") {
                it("will return error") {
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: callbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id, miniAppTitle: mockMiniAppTitle
                    )
                    let requestParam = RequestParameters(
                        action: "",
                        permission: "location",
                        permissions: nil,
                        locationOptions: nil,
                        shareInfo: ShareInfoParameters(content: ""),
                        adType: 0,
                        adUnitId: "",
                        audience: nil,
                        scopes: nil,
                        messageToContact: nil,
                        contactId: nil,
                        filename: nil,
                        url: nil,
                        headers: nil,
                        secureStorageKey: nil,
                        secureStorageItems: nil,
                        secureStorageKeyList: nil,
                        closeAlertInfo: nil,
                        jsonInfo: JsonStringInfoParameters(content: ""),
                        withConfirmationAlert: nil
                    )
                    let javascriptMessageInfo = MiniAppJavaScriptMessageInfo(action: "", id: "123", param: requestParam)
                    scriptMessageHandler.handleBridgeMessage(responseJson: javascriptMessageInfo)
                    expect(callbackProtocol.errorMessage).toEventually(contain(MiniAppJavaScriptError.unexpectedMessageFormat.rawValue))
                }
            }
            context("when handleBridgeMessage receive valid action, invalid id") {
                it("will return error") {
                    let requestParam = RequestParameters(
                        action: "",
                        permission: "location",
                        permissions: nil,
                        locationOptions: nil,
                        shareInfo: ShareInfoParameters(content: ""),
                        adType: 0,
                        adUnitId: "",
                        audience: nil,
                        scopes: nil,
                        messageToContact: nil,
                        contactId: nil,
                        filename: nil,
                        url: nil,
                        headers: nil,
                        secureStorageKey: nil,
                        secureStorageItems: nil,
                        secureStorageKeyList: nil,
                        closeAlertInfo: nil,
                        jsonInfo: JsonStringInfoParameters(content: ""),
                        withConfirmationAlert: nil
                    )
                    let javascriptMessageInfo = MiniAppJavaScriptMessageInfo(action: "getUniqueId", id: "", param: requestParam)
                    scriptMessageHandler.handleBridgeMessage(responseJson: javascriptMessageInfo)
                    expect(callbackProtocol.errorMessage).toEventually(contain(MiniAppJavaScriptError.unexpectedMessageFormat.rawValue))
                }
            }
            context("when handleBridgeMessage receive valid action, invalid messaging unique id") {
                it("will return error") {
                    let requestParam = RequestParameters(
                        action: "",
                        permission: "location",
                        permissions: nil,
                        locationOptions: nil,
                        shareInfo: ShareInfoParameters(content: ""),
                        adType: 0,
                        adUnitId: "",
                        audience: nil,
                        scopes: nil,
                        messageToContact: nil,
                        contactId: nil,
                        filename: nil,
                        url: nil,
                        headers: nil,
                        secureStorageKey: nil,
                        secureStorageItems: nil,
                        secureStorageKeyList: nil,
                        closeAlertInfo: nil,
                        jsonInfo: JsonStringInfoParameters(content: ""),
                        withConfirmationAlert: nil
                    )
                    let javascriptMessageInfo = MiniAppJavaScriptMessageInfo(action: "getMessagingUniqueId", id: "", param: requestParam)
                    scriptMessageHandler.handleBridgeMessage(responseJson: javascriptMessageInfo)
                    expect(callbackProtocol.errorMessage).toEventually(contain(MiniAppJavaScriptError.unexpectedMessageFormat.rawValue))
                }
            }
            context("when handleBridgeMessage receive valid action, invalid mauid") {
                it("will return error") {
                    let requestParam = RequestParameters(
                        action: "",
                        permission: "location",
                        permissions: nil,
                        locationOptions: nil,
                        shareInfo: ShareInfoParameters(content: ""),
                        adType: 0,
                        adUnitId: "",
                        audience: nil,
                        scopes: nil,
                        messageToContact: nil,
                        contactId: nil,
                        filename: nil,
                        url: nil,
                        headers: nil,
                        secureStorageKey: nil,
                        secureStorageItems: nil,
                        secureStorageKeyList: nil,
                        closeAlertInfo: nil,
                        jsonInfo: JsonStringInfoParameters(content: ""),
                        withConfirmationAlert: nil
                    )
                    let javascriptMessageInfo = MiniAppJavaScriptMessageInfo(action: "getMauid", id: "", param: requestParam)
                    scriptMessageHandler.handleBridgeMessage(responseJson: javascriptMessageInfo)
                    expect(callbackProtocol.errorMessage).toEventually(contain(MiniAppJavaScriptError.unexpectedMessageFormat.rawValue))
                }
            }
            context("when MiniAppScriptMessageHandler receives valid requestPermission command and request parameter, but user allow the location permission") {
                it("will return ALLOWED") {
                    mockMessageInterface.locationAllowed = true
                    let mockMessage = MockWKScriptMessage(name: "", body: "{\"action\": \"requestPermission\", \"param\": { \"permission\": \"location\"}, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.response).toEventually(equal("ALLOWED"))
                }
            }
            context("when MiniAppScriptMessageHandler receives valid requestPermission command and request parameter, but user denied the permission") {
                it("will return denied") {
                    mockMessageInterface.locationAllowed = false
                    let mockMessage = MockWKScriptMessage(name: "", body: "{\"action\": \"requestPermission\", \"param\": { \"permission\": \"location\"}, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.errorMessage).toEventually(contain("NOT_DETERMINED") || contain("DENIED"))
                }
            }
            context("when MiniAppScriptMessageHandler receives valid requestPermission command and request parameter, but user skipped the permission") {
                it("will return NotDetermined") {
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: callbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id, miniAppTitle: mockMiniAppTitle
                    )
                    mockMessageInterface.locationAllowed = false
                    mockMessageInterface.permissionError = .notDetermined
                    let mockMessage = MockWKScriptMessage(name: "", body: "{\"action\": \"requestPermission\", \"param\": { \"permission\": \"location\"}, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.errorMessage).toEventually(contain("NOT_DETERMINED"))
                }
            }
            context("when MiniAppScriptMessageHandler receives valid requestPermission command and invalid permission type") {
                it("will return invalidPermissionType error") {
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: callbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id, miniAppTitle: mockMiniAppTitle
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
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id, miniAppTitle: mockMiniAppTitle
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
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id, miniAppTitle: mockMiniAppTitle
                    )
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .deviceLocation, status: .allowed)
                    mockMessageInterface.locationAllowed = false
                    let mockMessage = MockWKScriptMessage(name: "", body: "{\"action\": \"getCurrentPosition\", \"param\":null, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    let status = CLLocationManager().authorizationStatus
                    if status == .authorizedAlways || status == .authorizedWhenInUse {
                        expect(callbackProtocol.response).toEventually(contain("latitude"))
                        expect(callbackProtocol.response).toEventually(contain("longitude"))
                    } else {
                        expect(callbackProtocol.errorMessage).toEventually(contain("application does not have sufficient geolocation permissions"))
                    }
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .deviceLocation, status: .denied)
                }
            }

            context("when MiniAppScriptMessageHandler receives valid custom permissions command and the permissions is allowed already") {
                it("will return response from cache with permission name and status for all permission that is requested") {
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .userName, status: .allowed)
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
                    if decodedObj.permissions.count > 0 {
                        expect(decodedObj.permissions[0].name).toEventually(equal("rakuten.miniapp.user.USER_NAME"), timeout: .seconds(10))
                        expect(decodedObj.permissions[0].status).toEventually(equal("ALLOWED"), timeout: .seconds(10))
                    } else {
                        fail("create MiniApp failure")
                    }
                }
            }
            context("when MiniAppScriptMessageHandler receives valid custom permissions command and if the permission is not allowed already") {
                it("will request host app to request those permissions and return the permission response with name and status for all permission that is requested") {
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .userName, status: .denied)
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
                    if decodedObj.permissions.count > 0 {
                        expect(decodedObj.permissions[0].name).toEventually(equal("rakuten.miniapp.user.USER_NAME"), timeout: .seconds(10))
                        expect(decodedObj.permissions[0].status).toEventually(equal("ALLOWED"), timeout: .seconds(10))
                    } else {
                        fail("create MiniApp failure")
                    }
                }
            }
            context("when MiniAppScriptMessageHandler receives valid custom permissions command but invalid permission object title instead of name") {
                it("will return error response with error title and description for permission that is requested") {
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
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id, miniAppTitle: mockMiniAppTitle
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
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: callbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id,
                        miniAppTitle: mockMiniAppTitle
                    )
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
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: callbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id,
                        miniAppTitle: mockMiniAppTitle
                    )
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
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id, miniAppTitle: mockMiniAppTitle
                    )
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .userName, status: .allowed)
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
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id, miniAppTitle: mockMiniAppTitle
                    )
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .userName, status: .allowed)
                    let mockMessage = MockWKScriptMessage(
                        name: "", body: "{\"action\": \"getUserName\", \"param\":null, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.errorMessage).toEventually(contain("hostAppError"), timeout: .seconds(10))
                }
                it("will return Error if User didn't allow User Name permission") {
                    mockMessageInterface.mockUserName = ""
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()

                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: mockCallbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id, miniAppTitle: mockMiniAppTitle
                    )
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .userName, status: .denied)
                    let mockMessage = MockWKScriptMessage(
                        name: "", body: "{\"action\": \"getUserName\", \"param\":null, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.errorMessage).toEventually(contain(MASDKCustomPermissionError.userNamePermissionError.rawValue), timeout: .seconds(10))
                }
            }
            context("when MiniAppScriptMessageHandler receives valid getProfilePhoto command") {
                it("will return Profile Photo if User has set the Profile photo in the User Profile") {
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    mockMessageInterface.mockProfilePhoto = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8wmD0HwAFPQInf/fUWQAAAABJRU5ErkJggg=="
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: mockCallbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id, miniAppTitle: mockMiniAppTitle
                    )
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .profilePhoto, status: .allowed)
                    let mockMessage = MockWKScriptMessage(
                        name: "", body: "{\"action\": \"getProfilePhoto\", \"param\":null, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.response).toEventually(contain(mockMessageInterface.mockProfilePhoto ?? ""), timeout: .seconds(10))
                }
                it("will return Error if User didn't set the Profile Photo in the User Profile") {
                    mockMessageInterface.mockProfilePhoto = nil
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: mockCallbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id, miniAppTitle: mockMiniAppTitle
                    )
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .profilePhoto, status: .allowed)
                    let mockMessage = MockWKScriptMessage(
                        name: "", body: "{\"action\": \"getProfilePhoto\", \"param\":null, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.errorMessage).toEventually(contain("hostAppError"), timeout: .seconds(10))
                }
                it("will return Error if User didn't allow Profile Photo permission") {
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: mockCallbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id, miniAppTitle: mockMiniAppTitle
                    )
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .profilePhoto, status: .denied)
                    let mockMessage = MockWKScriptMessage(
                        name: "", body: "{\"action\": \"getProfilePhoto\", \"param\":null, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.errorMessage).toEventually(contain(MASDKCustomPermissionError.profilePhotoPermissionError.rawValue), timeout: .seconds(10))
                }
            }
            context("when MiniAppScriptMessageHandler receives valid getContacts command") {
                let mockMessage = MockWKScriptMessage(
                   name: "", body: "{\"action\": \"getContacts\", \"param\":null, \"id\":\"12345\"}" as AnyObject)
                 it("will return contact list if User has contacts in the User Profile") {
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: mockCallbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id, miniAppTitle: "Mini App"
                    )
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .contactsList, status: .allowed)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.response).toEventually(contain("contact_id"), timeout: .seconds(10))
                 }
                it("will return Error if User didn't allow Contact permission") {
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                       delegate: mockCallbackProtocol,
                       hostAppMessageDelegate: mockMessageInterface,
                       adsDisplayer: mockAdsDelegate,
                       secureStorageDelegate: mockSecureStorageDelegate,
                       miniAppManageDelegate: mockMiniAppManageInterface,
                       miniAppId: mockMiniAppInfo.id, miniAppTitle: "Mini App"
                    )
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .contactsList, status: .denied)
                   scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.errorMessage).toEventually(contain(MASDKCustomPermissionError.contactsPermissionError.rawValue), timeout: .seconds(10))
                }
                it("will return Error if contacts are nil") {
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    mockMessageInterface.mockContactList = nil
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                       delegate: mockCallbackProtocol,
                       hostAppMessageDelegate: mockMessageInterface,
                       adsDisplayer: mockAdsDelegate,
                       secureStorageDelegate: mockSecureStorageDelegate,
                       miniAppManageDelegate: mockMiniAppManageInterface,
                       miniAppId: mockMiniAppInfo.id, miniAppTitle: "Mini App"
                    )
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .contactsList, status: .allowed)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.errorMessage).toEventually(contain(MiniAppJavaScriptError.internalError.rawValue), timeout: .seconds(10))
                }
            }
            context("when MiniAppScriptMessageHandler receives getAccessToken command without scopes") {
                it("will return an error") {
                    saveMockManifestInCache(miniAppId: mockMiniAppInfo.id)
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: mockCallbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id, miniAppTitle: mockMiniAppTitle
                    )
                    mockMessageInterface.mockAccessToken = "MOCK_ACCESS_TOKEN"
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .accessToken, status: .allowed)
                    let mockMessage = MockWKScriptMessage(
                        name: "", body: "{\"action\": \"getAccessToken\", \"param\":null, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.response).toEventually(beNil(), timeout: .seconds(2))
                    expect(mockCallbackProtocol.errorMessage).toEventually(contain(MASDKAccessTokenError.audienceNotSupportedError.name), timeout: .seconds(2))
                }
            }
            context("when MiniAppScriptMessageHandler receives getAccessToken command with bad audience") {
                it("will return an error") {
                    saveMockManifestInCache(miniAppId: mockMiniAppInfo.id)
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                            delegate: mockCallbackProtocol,
                            hostAppMessageDelegate: mockMessageInterface,
                            adsDisplayer: mockAdsDelegate,
                            secureStorageDelegate: mockSecureStorageDelegate,
                            miniAppManageDelegate: mockMiniAppManageInterface,
                            miniAppId: mockMiniAppInfo.id, miniAppTitle: mockMiniAppTitle
                    )
                    mockMessageInterface.mockAccessToken = "MOCK_ACCESS_TOKEN"
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .accessToken, status: .allowed)
                    let mockMessage = MockWKScriptMessage(
                            name: "", body: "{\"action\": \"getAccessToken\", \"param\":{\"audience\": \"bad_audience\", \"scopes\":[\"test\"]}, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.response).toEventually(beNil(), timeout: .seconds(2))
                    expect(mockCallbackProtocol.errorMessage).toEventually(contain(MASDKAccessTokenError.audienceNotSupportedError.name), timeout: .seconds(2))
                }
            }
            context("when MiniAppScriptMessageHandler receives getAccessToken command with bad scopes") {
                it("will return an error") {
                    saveMockManifestInCache(miniAppId: mockMiniAppInfo.id)
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                            delegate: mockCallbackProtocol,
                            hostAppMessageDelegate: mockMessageInterface,
                            adsDisplayer: mockAdsDelegate,
                            secureStorageDelegate: mockSecureStorageDelegate,
                            miniAppManageDelegate: mockMiniAppManageInterface,
                            miniAppId: mockMiniAppInfo.id, miniAppTitle: mockMiniAppTitle
                    )
                    mockMessageInterface.mockAccessToken = "MOCK_ACCESS_TOKEN"
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .accessToken, status: .allowed)
                    let mockMessage = MockWKScriptMessage(
                            name: "", body: "{\"action\": \"getAccessToken\", \"param\":{\"audience\": \"AUDIENCE_TEST\", \"scopes\":[\"bad_scope\"]}, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.response).toEventually(beNil(), timeout: .seconds(2))
                    expect(mockCallbackProtocol.errorMessage).toEventually(contain(MASDKAccessTokenError.scopesNotSupportedError.name), timeout: .seconds(2))
                }
            }
            context("when MiniAppScriptMessageHandler receives valid getAccessToken command") {
                it("will return Access Token data info such as Token string and expiry date") {
                    saveMockManifestInCache(miniAppId: mockMiniAppInfo.id)
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                            delegate: mockCallbackProtocol,
                            hostAppMessageDelegate: mockMessageInterface,
                            adsDisplayer: mockAdsDelegate,
                            secureStorageDelegate: mockSecureStorageDelegate,
                            miniAppManageDelegate: mockMiniAppManageInterface,
                            miniAppId: mockMiniAppInfo.id, miniAppTitle: mockMiniAppTitle
                    )
                    mockMessageInterface.mockAccessToken = "MOCK_ACCESS_TOKEN"
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .accessToken, status: .allowed)
                    let mockMessage = MockWKScriptMessage(
                            name: "", body: "{\"action\": \"getAccessToken\", \"param\":{\"audience\": \"AUDIENCE_TEST\", \"scopes\":[\"scope_test\"]}, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.response).toEventually(contain(mockMessageInterface.mockAccessToken!), timeout: .seconds(2))
                }
            }
            context("when MiniAppScriptMessageHandler receives valid getAccessToken command but host app returns error") {
                it("will return error") {
                    saveMockManifestInCache(miniAppId: mockMiniAppInfo.id)
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: mockCallbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id, miniAppTitle: mockMiniAppTitle
                    )
                    mockMessageInterface.mockAccessToken = ""
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .accessToken, status: .allowed)
                    let mockMessage = MockWKScriptMessage(
                        name: "", body: "{\"action\": \"getAccessToken\", \"param\":{\"audience\": \"AUDIENCE_TEST\", \"scopes\":[\"scope_test\"]}, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.errorMessage).toEventually(contain("Unable to return Access Token"), timeout: .seconds(2))
                }
                it("will return Error if User didn't allow Access Token permission") {
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: mockCallbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id, miniAppTitle: mockMiniAppTitle
                    )
                    mockMessageInterface.mockAccessToken = ""
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .accessToken, status: .denied)
                    let mockMessage = MockWKScriptMessage(
                        name: "", body: "{\"action\": \"getAccessToken\", \"param\":{\"audience\": \"AUDIENCE_TEST\", \"scopes\":[\"scope_test\"]}, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.errorMessage).toEventually(contain(MASDKCustomPermissionError.accessTokenPermissionError.rawValue), timeout: .seconds(10))
                }
            }
            context("when MiniApp manifest contained no scopes") {
                it("will return error") {
                    removeMockManifestInCache(miniAppId: mockMiniAppInfo.id)
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                            delegate: mockCallbackProtocol,
                            hostAppMessageDelegate: mockMessageInterface,
                            adsDisplayer: mockAdsDelegate,
                            secureStorageDelegate: mockSecureStorageDelegate,
                            miniAppManageDelegate: mockMiniAppManageInterface,
                            miniAppId: mockMiniAppInfo.id, miniAppTitle: mockMiniAppTitle
                    )
                    mockMessageInterface.mockAccessToken = ""
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .accessToken, status: .allowed)
                    let mockMessage = MockWKScriptMessage(
                            name: "", body: "{\"action\": \"getAccessToken\", \"param\":{\"audience\": \"AUDIENCE_TEST\", \"scopes\":[\"scope_test\"]}, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.response).toEventually(beNil(), timeout: .seconds(2))
                    expect(mockCallbackProtocol.errorMessage).toEventually(contain(MASDKAccessTokenError.audienceNotSupportedError.name), timeout: .seconds(2))
                }
            }
            context("when MiniAppScriptMessageHandler receives invalid orientation lock command") {
                it("will return error") {
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: mockCallbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                            adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id, miniAppTitle: mockMiniAppTitle
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
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id, miniAppTitle: mockMiniAppTitle
                    )
                    mockMessageInterface.messageContentAllowed = false
                    let mockMessage = MockWKScriptMessage(
                        name: "", body: "{\"action\":\"setScreenOrientation\",\"param\":{\"action\":\"rakuten.miniapp.screen.LOCK_LANDSCAPE_RIGHT\"},\"id\":\"5.733550049709592\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.errorMessage).toEventually(contain(MiniAppJavaScriptError.unexpectedMessageFormat.rawValue), timeout: .seconds(10))
                }
            }
            context("when MiniAppScriptMessageHandler receives sendMessageToContact command") {
                it("will return valid success message") {
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: mockCallbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id, miniAppTitle: mockMiniAppTitle
                    )
                    mockMessageInterface.messageContentAllowed = true
                    let command = """
                    {
                      "action" : "sendMessageToContact",
                      "id" : "1.9034416849400426",
                      "param" : {
                        "messageToContact" : {
                          "action" : "\(mockHost)\",
                          "caption" : "Sample caption",
                          "image" : "data:image/png;base64,Test==",
                          "text" : "Sample text"
                        }
                      }
                    }
                    """
                    let mockMessage = MockWKScriptMessage(name: "", body: command as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.response).toEventually(contain("SUCCESS"), timeout: .seconds(5))
                }
            }
            context("when MiniAppScriptMessageHandler receives sendMessageToContact command but Host app couldn't send the message") {
                it("will return error") {
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: mockCallbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id, miniAppTitle: mockMiniAppTitle
                    )
                    mockMessageInterface.messageContentAllowed = false
                    let command = """
                    {
                      "action" : "sendMessageToContact",
                      "id" : "1.9034416849400426",
                      "param" : {
                        "messageToContact" : {
                          "action" : "\(mockHost)\",
                          "caption" : "Sample caption",
                          "image" : "data:image/png;base64,Test==",
                          "text" : "Sample text"
                        }
                      }
                    }
                    """
                    let mockMessage = MockWKScriptMessage(name: "", body: command as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.errorMessage).toEventually(contain(MASDKError.invalidContactId.errorDescription ?? ""), timeout: .seconds(5))
                }
            }
            context("when MiniAppScriptMessageHandler receives sendMessageToContactId command") {
                it("will return contact Id") {
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: mockCallbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id, miniAppTitle: mockMiniAppTitle
                    )
                    mockMessageInterface.messageContentAllowed = true
                    let command = """
                    {
                        "action" : "sendMessageToContactId",
                        "id" : "4.1141101534045745",
                        "param" : {
                            "contactId" : "\(mockMiniAppInfo.id)",
                            "messageToContact" : {
                                "action" : "\(mockHost)/",
                                "caption" : "Sample caption",
                                "image" : "data:image/png;base64,Test==",
                                "text" : "Sample text"
                            }
                        }
                    }
                    """
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .sendMessage, status: .allowed)
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .contactsList, status: .allowed)
                    let mockMessage = MockWKScriptMessage(name: "", body: command as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.response).toEventually(contain(mockMiniAppInfo.id), timeout: .seconds(5))
                }
            }
            context("when MiniAppScriptMessageHandler receives sendMessageToContactId command but contact ID is not found") {
                it("will return error") {
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: mockCallbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id, miniAppTitle: mockMiniAppTitle
                    )
                    mockMessageInterface.messageContentAllowed = false
                    let command = """
                    {
                        "action" : "sendMessageToContactId",
                        "id" : "4.1141101534045745",
                        "param" : {
                            "contactId" : "\(mockMiniAppInfo.id)",
                            "messageToContact" : {
                                "action" : "\(mockHost)/",
                                "caption" : "Sample caption",
                                "image" : "data:image/png;base64,Test==",
                                "text" : "Sample text"
                            }
                        }
                    }
                    """
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .sendMessage, status: .allowed)
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .contactsList, status: .allowed)
                    let mockMessage = MockWKScriptMessage(name: "", body: command as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.errorMessage).toEventually(contain(MASDKError.invalidContactId.errorDescription ?? ""), timeout: .seconds(5))
                }
            }
            context("when MiniAppScriptMessageHandler receives sendMessageToMultipleContacts command") {
                it("will return list of contact Ids") {
                    mockMessageInterface.messageContentAllowed = true
                    let command = """
                    {
                        "action" : "sendMessageToMultipleContacts",
                        "id" : "5.1141101534045745",
                        "param" : {
                            "messageToContact" : {
                                "action" : "\(mockHost)/",
                                "caption" : "Sample caption",
                                "image" : "data:image/png;base64,Test==",
                                "text" : "Sample text"
                            }
                        }
                    }
                    """
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .sendMessage, status: .allowed)
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .contactsList, status: .allowed)

                    let mockMessage = MockWKScriptMessage(name: "", body: command as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.response).toEventually(contain(["contact_id1", "contact_id2"]), timeout: .seconds(5))
                }
            }
            context("when MiniAppScriptMessageHandler receives sendMessageToMultipleContacts command") {
                it("will return list of contact Ids") {
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: mockCallbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id, miniAppTitle: mockMiniAppTitle
                    )
                    mockMessageInterface.messageContentAllowed = false
                    let command = """
                    {
                        "action" : "sendMessageToMultipleContacts",
                        "id" : "5.1141101534045745",
                        "param" : {
                            "messageToContact" : {
                                "action" : "\(mockHost)/",
                                "caption" : "Sample caption",
                                "image" : "data:image/png;base64,Test==",
                                "text" : "Sample text"
                            }
                        }
                    }
                    """
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .sendMessage, status: .allowed)
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .contactsList, status: .allowed)

                    let mockMessage = MockWKScriptMessage(name: "", body: command as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.errorMessage).toEventually(contain(MASDKError.invalidContactId.errorDescription ?? ""), timeout: .seconds(5))
                }
            }
            context("when MiniAppScriptMessageHandler receives sendMessageToContact command") {
                it("will return valid success message") {
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: mockCallbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id, miniAppTitle: mockMiniAppTitle
                    )
                    mockMessageInterface.messageContentAllowed = false
                    let command = """
                    {
                      "action" : "sendMessageToContact",
                      "id" : "1.9034416849400426",
                      "param" : {
                        "messageToContact" : null
                      }
                    }
                    """
                    let mockMessage = MockWKScriptMessage(name: "", body: command as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.errorMessage).toEventually(contain(MiniAppJavaScriptError.unexpectedMessageFormat.rawValue), timeout: .seconds(5))
                }
            }
            context("when MiniAppScriptMessageHandler receives sendMessageToContactId command") {
                it("will return contact Id") {
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: mockCallbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id, miniAppTitle: mockMiniAppTitle
                    )
                    mockMessageInterface.messageContentAllowed = false
                    let command = """
                    {
                        "action" : "sendMessageToContactId",
                        "id" : "4.1141101534045745",
                        "param" : {
                            "contactId" : "\(mockMiniAppInfo.id)",
                            "messageToContact" : null
                        }
                    }
                    """
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .sendMessage, status: .allowed)
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .contactsList, status: .allowed)

                    let mockMessage = MockWKScriptMessage(name: "", body: command as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.errorMessage).toEventually(contain(MiniAppJavaScriptError.unexpectedMessageFormat.rawValue), timeout: .seconds(5))
                }
            }
            context("when MiniAppScriptMessageHandler receives sendMessageToMultipleContacts command") {
                it("will return list of contact Ids") {
                    mockMessageInterface.messageContentAllowed = false
                    let command = """
                    {
                        "action" : "sendMessageToMultipleContacts",
                        "id" : "5.1141101534045745",
                        "param" : {
                            "messageToContact" : null
                    }
                    """
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .sendMessage, status: .allowed)
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .contactsList, status: .allowed)
                    let mockMessage = MockWKScriptMessage(name: "", body: command as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.errorMessage).toEventually(contain(MiniAppJavaScriptError.unexpectedMessageFormat.rawValue), timeout: .seconds(5))
                }
            }
            context("when MiniAppScriptMessageHandler receives getPoints command and permission is denied") {
                it("will error") {
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: mockCallbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id, miniAppTitle: mockMiniAppTitle
                    )
                    let command = """
                    {
                        "action" : "getPoints",
                        "id" : "5.1141101534045745",
                        "param" : null
                    }
                    """
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .points, status: .denied)
                    let mockMessage = MockWKScriptMessage(name: "", body: command as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.errorMessage).toEventually(contain(MASDKCustomPermissionError.pointsPermissionError.rawValue), timeout: .seconds(10))

                }
            }
            context("when MiniAppScriptMessageHandler receives getPoints command and permission is allowed") {
                it("will return list of contact Ids") {
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: mockCallbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id, miniAppTitle: mockMiniAppTitle
                    )
                    let command = """
                    {
                        "action" : "getPoints",
                        "id" : "5.1141101534045745",
                        "param" : null
                    }
                    """
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .points, status: .allowed)
                    mockMessageInterface.mockPointsInterface = false
                    let mockMessage = MockWKScriptMessage(name: "", body: command as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.errorMessage).toEventually(contain("Failed to retrieve Points details"), timeout: .seconds(10))

                }
            }
            context("when MiniAppScriptMessageHandler receives getPoints command and permission is allowed") {
                it("will return list of contact Ids") {
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: mockCallbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id, miniAppTitle: mockMiniAppTitle
                    )
                    let command = """
                    {
                        "action" : "getPoints",
                        "id" : "5.1141101534045745",
                        "param" : null
                    }
                    """
                    updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .points, status: .allowed)
                    mockMessageInterface.mockPointsInterface = true
                    let mockMessage = MockWKScriptMessage(name: "", body: command as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.response).toEventually(contain("standard"), timeout: .seconds(10))
                }
            }
            context("when MiniAppScriptMessageHandler receives getHostEnvironmentInfo command") {
                it("will return ") {
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: mockCallbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id, miniAppTitle: mockMiniAppTitle
                    )
                    let command = """
                    {
                        "action" : "getHostEnvironmentInfo",
                        "id" : "5.1141101534045745",
                        "param" : null
                    }
                    """
                    mockMessageInterface.mockEnvironmentInfo = true
                    let mockMessage = MockWKScriptMessage(name: "", body: command as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    guard let responseData: Data = mockCallbackProtocol.response?.data(using: .utf8) else {
                        fail("MiniAppScriptMessageHandler - getHostEnvironmentInfo failed")
                        return
                    }
                    let environmentInfo = ResponseDecoder.decode(decodeType: MAHostEnvironmentInfo.self, data: responseData)
                        expect(environmentInfo?.sdkVersion).toEventually(equal("5.3.0"))
                    expect(environmentInfo?.hostVersion).toEventually(equal(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String))
                    expect(environmentInfo?.hostLocale).toEventually(equal("en-US"))
                }
            }
            context("when MiniAppScriptMessageHandler receives downloadFile command") {
                it("will return file name on success") {
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: mockCallbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id,
                        miniAppTitle: mockMiniAppTitle
                    )
                    let command = """
                    {
                        "action" : "downloadFile",
                        "id" : "5.1141101534045745",
                        "param": {
                            "filename" : "sample.jpg",
                            "url" : "https://rakuten.co.jp/sample.jpg",
                            "headers" : { "token": "test" }
                        }
                    }
                    """
                    updateCustomPermissionStatus(
                        miniAppId: mockMiniAppInfo.id,
                        permissionType: .fileDownload,
                        status: .allowed
                    )
                    mockMessageInterface.mockDownloadFile = true
                    let mockMessage = MockWKScriptMessage(name: "", body: command as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.response).toEventually(equal("sample.jpg"))
                }
                it("will return nil on failure") {
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: mockCallbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id,
                        miniAppTitle: mockMiniAppTitle
                    )
                    let command = """
                    {
                        "action" : "downloadFile",
                        "id" : "5.1141101534045745",
                        "param": {
                            "filename" : "sample.jpg",
                            "url" : "https://rakuten.co.jp/sample.jpg",
                            "headers" : { "token": "test" }
                        }
                    }
                    """
                    updateCustomPermissionStatus(
                        miniAppId: mockMiniAppInfo.id,
                        permissionType: .fileDownload,
                        status: .allowed
                    )
                    mockMessageInterface.mockDownloadFile = false
                    let mockMessage = MockWKScriptMessage(name: "", body: command as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.response).toEventually(beNil())
                }
            }
            context("when MiniAppScriptMessageHandler executes keyboard events") {
                it("keyboard shown succeeds") {
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: mockCallbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id, miniAppTitle: mockMiniAppTitle
                    )
                    scriptMessageHandler.execKeyboardEventsCallback(with: .keyboardShown, message: "keyboard shown", navigationBarHeight: 100, screenHeight: 200, keyboardHeight: 300)
                    expect(mockCallbackProtocol.navBarHeight).to(equal(100))
                    expect(mockCallbackProtocol.screenHeight).to(equal(200))
                    expect(mockCallbackProtocol.keyboardHeight).to(equal(300))
                }
                it("keyboard hidden succeeds") {
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: mockCallbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id, miniAppTitle: mockMiniAppTitle
                    )
                    scriptMessageHandler.execKeyboardEventsCallback(with: .keyboardHidden, message: "keyboard hidden", navigationBarHeight: 100, screenHeight: 200, keyboardHeight: 300)
                    expect(mockCallbackProtocol.navBarHeight).to(equal(100))
                    expect(mockCallbackProtocol.screenHeight).to(equal(200))
                    expect(mockCallbackProtocol.keyboardHeight).to(equal(300))
                }
            }
            context("when MiniAppScriptMessageHandler receives setCloseAlert command") {
                it("will set the Mini app close alert info in the SDK") {
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: mockCallbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id,
                        miniAppTitle: mockMiniAppTitle
                    )
                    let command = """
                    {
                        "action" : "setCloseAlert",
                        "id" : "5.114110153404574",
                        "param": {
                            "closeAlertInfo": {
                                "shouldDisplay" : true,
                                "title" : "Info",
                                "description" : "Would you like to close the mini-app?"
                            }
                        }
                    }
                    """
                    mockMessageInterface.mockDownloadFile = true
                    let mockMessage = MockWKScriptMessage(name: "", body: command as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.response).toEventually(equal("SUCCESS"))
                }
                it("received wrong params then it will throw error") {
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: mockCallbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id,
                        miniAppTitle: mockMiniAppTitle
                    )
                    let command = """
                    {
                        "action" : "setCloseAlert",
                        "id" : "5.114110153404574",
                        "param": {
                            "closeAlertInfo": {
                                "shouldDisplay" : "true",
                                "title" : "Info",
                                "description" : "Would you like to close the mini-app?"
                            }
                        }
                    }
                    """
                    mockMessageInterface.mockDownloadFile = true
                    let mockMessage = MockWKScriptMessage(name: "", body: command as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.errorMessage).toEventually(contain(MiniAppJavaScriptError.unexpectedMessageFormat.rawValue))
                }
                it("received empty params then it will throw error") {
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: mockCallbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id,
                        miniAppTitle: mockMiniAppTitle
                    )
                    let command = """
                    {
                        "action" : "setCloseAlert",
                        "id" : "5.114110153404574",
                        "param": {}
                    }
                    """
                    mockMessageInterface.mockDownloadFile = true
                    let mockMessage = MockWKScriptMessage(name: "", body: command as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.errorMessage).toEventually(contain(MiniAppJavaScriptError.unexpectedMessageFormat.rawValue))
                }
            }
            context("when MiniAppScriptMessageHandler receives SecureStorage commands") {
                it("will set some items") {
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: mockCallbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id,
                        miniAppTitle: mockMiniAppTitle
                    )
                    let command = """
                    {
                        "action" : "setSecureStorageItems",
                        "id" : "5.114110153404574",
                        "param": {
                            "secureStorageItems": {
                                "test1" : "value1",
                                "test2" : "value2",
                                "test3" : "value3"
                            }
                        }
                    }
                    """
                    let mockMessage = MockWKScriptMessage(name: "", body: command as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.response).toEventually(equal("success"))
                }
                it("will get an empty result for a non existing key") {
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: mockCallbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id,
                        miniAppTitle: mockMiniAppTitle
                    )
                    let command = """
                    {
                        "action" : "getSecureStorageItem",
                        "id" : "5.114110153404574",
                        "param": {
                            "secureStorageKey": "test1"
                        }
                    }
                    """
                    let mockMessage = MockWKScriptMessage(name: "", body: command as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.response).toEventually(equal(""))
                }
                it("will remove a couple of keys") {
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: mockCallbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id,
                        miniAppTitle: mockMiniAppTitle
                    )
                    let command = """
                    {
                        "action" : "removeSecureStorageItems",
                        "id" : "5.114110153404574",
                        "param": {
                            "secureStorageKeyList": [
                                "test1",
                                "test2",
                                "test3"
                            ]
                        }
                    }
                    """
                    let mockMessage = MockWKScriptMessage(name: "", body: command as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.response).toEventually(equal("success"))
                }
                it("will clear storages") {
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: mockCallbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id,
                        miniAppTitle: mockMiniAppTitle
                    )
                    let command = """
                    {
                        "action" : "clearSecureStorage",
                        "id" : "5.114110153404574",
                        "param": {}
                    }
                    """
                    let mockMessage = MockWKScriptMessage(name: "", body: command as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.response).toEventually(equal("success"))
                }
                it("will get secure storage file size") {
                    let mockCallbackProtocol = MockMiniAppCallbackProtocol()
                    let scriptMessageHandler = MiniAppScriptMessageHandler(
                        delegate: mockCallbackProtocol,
                        hostAppMessageDelegate: mockMessageInterface,
                        adsDisplayer: mockAdsDelegate,
                        secureStorageDelegate: mockSecureStorageDelegate,
                        miniAppManageDelegate: mockMiniAppManageInterface,
                        miniAppId: mockMiniAppInfo.id,
                        miniAppTitle: mockMiniAppTitle
                    )
                    let command = """
                    {
                        "action" : "getSecureStorageSize",
                        "id" : "5.114110153404574",
                        "param": {}
                    }
                    """
                    let mockMessage = MockWKScriptMessage(name: "", body: command as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(mockCallbackProtocol.response).toEventually(equal("{\"used\":0,\"max\":2000000}"))
                }
            }
            context("when MiniAppScriptMessageHandler receives sendJsonToHostApp info message") {
                let scriptMessageHandler = MiniAppScriptMessageHandler(
                    delegate: callbackProtocol,
                    hostAppMessageDelegate: mockMessageInterface,
                    adsDisplayer: mockAdsDelegate,
                    secureStorageDelegate: mockSecureStorageDelegate,
                    miniAppManageDelegate: mockMiniAppManageInterface,
                    miniAppId: mockMiniAppInfo.id,
                    miniAppTitle: mockMiniAppTitle
                )
                it("will return SUCCESS after host app recieves valid content strig") {
                    mockMessageInterface.mockInterfaceImplemented = true
                    let command = "{\"action\":\"sendJsonToHostapp\",\"param\":{\"jsonInfo\":{\"content\":\"{\\\"data\\\":\\\"Thisisasamplejsoninformation\\\"}\"}},\"id\":\"10.050192665128856\"}"
                    let mockMessage = MockWKScriptMessage(name: "", body: command as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.response).toEventuallyNot(beNil(), timeout: .seconds(10))
                    expect(callbackProtocol.response).toEventually(equal(MASDKProtocolResponse.success.rawValue), timeout: .seconds(10))
                }
                it("will return failedToConformToProtocol Error when message interface is nil") {
                    mockMessageInterface.mockInterfaceImplemented = false
                    let command = "{\"action\":\"sendJsonToHostapp\",\"param\":{\"jsonInfo\":{\"content\":\"{\\\"data\\\":\\\"Thisisasamplejsoninformation\\\"}\"}},\"id\":\"10.050192665128856\"}"
                    let mockMessage = MockWKScriptMessage(name: "", body: command as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.errorMessage).toEventually(contain(UniversalBridgeError.failedToConformToProtocol.name))
                }
                it("will return empty value Error when content is empty") {
                    let command = "{\"action\":\"sendJsonToHostapp\",\"param\":{\"jsonInfo\":{\"content\":\"\"}},\"id\":\"10.050192665128856\"}"
                    let mockMessage = MockWKScriptMessage(name: "", body: command as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.errorMessage).toEventually(contain(MiniAppJavaScriptError.valueIsEmpty.rawValue))
                }
                it("will return Error unexpected message format when jsonInfo parameter is empty") {
                    let command = "{\"action\":\"sendJsonToHostapp\",\"param\":{},\"id\":\"10.050192665128856\"}"
                    let mockMessage = MockWKScriptMessage(
                        name: "", body: command as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.errorMessage).toEventually(contain(MiniAppJavaScriptError.unexpectedMessageFormat.name))
                }
            }
            context("when host app recieve the closeMiniApp(withConfirmationAlert:) action") {
                let scriptMessageHandler = MiniAppScriptMessageHandler(
                    delegate: callbackProtocol,
                    hostAppMessageDelegate: mockMessageInterface,
                    adsDisplayer: mockAdsDelegate,
                    secureStorageDelegate: mockSecureStorageDelegate,
                    miniAppManageDelegate: mockMiniAppManageInterface,
                    miniAppId: mockMiniAppInfo.id,
                    miniAppTitle: mockMiniAppTitle
                )
                it("if protocol implemented the miniapp will be closed and success will be returned") {
                    mockMessageInterface.mockInterfaceImplemented = true
                    let command = "{\"action\":\"closeMiniApp\",\"param\":{\"withConfirmationAlert\":true},\"id\":\"11.4876229746876\"}"
                    let mockMessage = MockWKScriptMessage(name: "", body: command as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.response).toEventuallyNot(beNil(), timeout: .seconds(10))
                    expect(callbackProtocol.response).toEventually(equal(MASDKProtocolResponse.success.rawValue), timeout: .seconds(10))
                }
                it("if protocol delegate not implemented, will throw failed to confirm to protocol error") {
                    mockMessageInterface.mockInterfaceImplemented = false
                    let command = "{\"action\":\"closeMiniApp\",\"param\":{\"withConfirmationAlert\":true},\"id\":\"11.4876229746876\"}"
                    let mockMessage = MockWKScriptMessage(name: "", body: command as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.errorMessage).toEventually(contain(MASDKError.failedToConformToProtocol.errorDescription ??  ""))
                }
                it("will return Error unexpected message format when jsonInfo parameter is empty") {
                    mockMessageInterface.mockInterfaceImplemented = true
                    let command = "{\"action\":\"closeMiniApp\",\"param\":{\"wrongKeyName\":true},\"id\":\"11.4876229746876\"}"
                    let mockMessage = MockWKScriptMessage(
                        name: "", body: command as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.errorMessage).toEventually(contain(MiniAppJavaScriptError.unexpectedMessageFormat.name))
                }
            }
            context("when user controller receive getHostAppThemeColors action and id") {
                let scriptMessageHandler = MiniAppScriptMessageHandler(
                    delegate: callbackProtocol,
                    hostAppMessageDelegate: mockMessageInterface,
                    adsDisplayer: mockAdsDelegate,
                    secureStorageDelegate: mockSecureStorageDelegate,
                    miniAppManageDelegate: mockMiniAppManageInterface,
                    miniAppId: mockMiniAppInfo.id,
                    miniAppTitle: mockMiniAppTitle
                )
                it("will return host app theme primary and secondary colors") {
                    mockMessageInterface.mockInterfaceImplemented = true
                    mockMessageInterface.mockHostAppThemeColorsAllowed = true
                    let mockMessage = MockWKScriptMessage(name: "getHostAppThemeColors", body: "{\"action\":\"getHostAppThemeColors\",\"param\":null,\"id\":\"9.408169489793705\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.messageId).toEventually(equal("9.408169489793705"))
                    expect(callbackProtocol.response).toEventuallyNot(beNil())
                }
                it("on error to get host app theme primary and secondary colors") {
                    mockMessageInterface.mockInterfaceImplemented = true
                    mockMessageInterface.mockHostAppThemeColorsAllowed = false
                    let mockMessage = MockWKScriptMessage(name: "getHostAppThemeColors", body: "{\"action\":\"getHostAppThemeColors\",\"param\":null,\"id\":\"9.408169489793705\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.messageId).toEventually(equal("9.408169489793705"))
                    expect(callbackProtocol.errorMessage).toEventually(contain(MiniAppJavaScriptError.unexpectedMessageFormat.name))
                }
                it("on failed to implement method error will return host app failed to implement protocol") {
                    mockMessageInterface.mockInterfaceImplemented = false
                    mockMessageInterface.mockHostAppThemeColorsAllowed = true
                    let mockMessage = MockWKScriptMessage(name: "getHostAppThemeColors", body: "{\"action\":\"getHostAppThemeColors\",\"param\":null,\"id\":\"9.408169489793705\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.errorMessage).toEventually(contain(MASDKError.failedToConformToProtocol.errorDescription ??  ""))
                }
            }
            context("when user controller receive isDarkMode action and id") {
                let scriptMessageHandler = MiniAppScriptMessageHandler(
                    delegate: callbackProtocol,
                    hostAppMessageDelegate: mockMessageInterface,
                    adsDisplayer: mockAdsDelegate,
                    secureStorageDelegate: mockSecureStorageDelegate,
                    miniAppManageDelegate: mockMiniAppManageInterface,
                    miniAppId: mockMiniAppInfo.id,
                    miniAppTitle: mockMiniAppTitle
                )
                it("will return true if the device is set to dark mode") {
                    mockMessageInterface.mockIsDarkMode = true
                    let mockMessage = MockWKScriptMessage(name: "isDarkMode", body: "{\"action\":\"isDarkMode\",\"param\":null,\"id\":\"9.408169489793706\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.messageId).toEventually(equal("9.408169489793705"))
                    expect(callbackProtocol.response).toEventually(equal("true"))
                }
                it("will return false if the device is NOT set to dark mode") {
                    mockMessageInterface.mockIsDarkMode = true
                    let mockMessage = MockWKScriptMessage(name: "isDarkMode", body: "{\"action\":\"isDarkMode\",\"param\":null,\"id\":\"9.408169489793706\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.messageId).toEventually(equal("9.408169489793705"))
                    expect(callbackProtocol.response).toEventually(equal("false"))
                }
            }
        }
    }
}
