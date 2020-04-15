import Quick
import Nimble
import WebKit
@testable import MiniApp

class MiniAppScriptMessageHandlerTests: QuickSpec {

    override func spec() {
        describe("Mini App Script message handler test") {
            let callbackProtocol = MockMiniAppCallbackProtocol()
            let mockMessageInterface = MockMessageInterface()

            let scriptMessageHandler = MiniAppScriptMessageHandler(delegate: callbackProtocol, hostMessageInterface: mockMessageInterface)
            context("when user controller recieve valid action and id") {
                it("will return unique id") {
                    mockMessageInterface.mockUniqueId = false
                    let mockMessage = MockWKScriptMessage(name: "getUniqueId", body: "{\"action\":\"getUniqueId\",\"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.messageId).toEventually(equal("12345"))
                    expect(callbackProtocol.response).toEventuallyNot(beNil())
                }
            }
            context("when user controller recieve valid action and id but failed to retrieve unique id") {
                it("will return error") {
                    mockMessageInterface.mockUniqueId = true
                    let scriptMessageHandler = MiniAppScriptMessageHandler(delegate: callbackProtocol, hostMessageInterface: mockMessageInterface)
                    let mockMessage = MockWKScriptMessage(name: "", body: "{\"action\":\"getUniqueId\",\"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(callbackProtocol.messageId).toEventually(equal("12345"))
                    expect(callbackProtocol.errorMessage).toEventually(equal(MiniAppJavaScriptError.internalError.rawValue))                }
            }
            context("when handleBridgeMessage recieve invalid action, valid id") {
                it("will return error") {
                    let scriptMessageHandler = MiniAppScriptMessageHandler(delegate: callbackProtocol, hostMessageInterface: mockMessageInterface)
                    let javascriptMessageInfo = MiniAppJavaScriptMessageInfo(action: "", id: "123")
                    scriptMessageHandler.handleBridgeMessage(responseJson: javascriptMessageInfo)
                    expect(callbackProtocol.errorMessage).toEventually(equal(MiniAppJavaScriptError.unexpectedMessageFormat.rawValue))
                }
            }
            context("when handleBridgeMessage recieve valid action, invalid id") {
                it("will return error") {
                    let scriptMessageHandler = MiniAppScriptMessageHandler(delegate: callbackProtocol, hostMessageInterface: mockMessageInterface)
                    let javascriptMessageInfo = MiniAppJavaScriptMessageInfo(action: "getUniqueId", id: "")
                    scriptMessageHandler.handleBridgeMessage(responseJson: javascriptMessageInfo)
                    expect(callbackProtocol.errorMessage).toEventually(equal(MiniAppJavaScriptError.unexpectedMessageFormat.rawValue))
                }
            }
            context("when handleActionCommand recieve valid action, but failed to retrieve unique id") {
                it("will return error") {
                    mockMessageInterface.mockUniqueId = true
                    let scriptMessageHandler = MiniAppScriptMessageHandler(delegate: callbackProtocol, hostMessageInterface: mockMessageInterface)
                    scriptMessageHandler.sendUniqueId(messageId: "1234")
                    expect(callbackProtocol.errorMessage).toEventually(equal(MiniAppJavaScriptError.internalError.rawValue))
                }
            }
        }
    }
}
