import Foundation
import WebKit

protocol MiniAppCallbackProtocol: AnyObject {
    func didRecieveScriptMessageResponse(messageId: String, response: String)
    func didRecieveScriptMessageError(messageId: String, errorMessage: String)
}

internal class MiniAppScriptMessageHandler: NSObject, WKScriptMessageHandler {

    weak var delegate: MiniAppCallbackProtocol?
    var hostAppMessageDelegate: MiniAppMessageProtocol?

    init(delegate: MiniAppCallbackProtocol, hostAppMessageDelegate: MiniAppMessageProtocol) {
        self.delegate = delegate
        self.hostAppMessageDelegate = hostAppMessageDelegate
        super.init()
    }

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if let messageBody = message.body as? String {
                let bodyData: Data = messageBody.data(using: .utf8)!
                let responseJson = try? JSONDecoder().decode(MiniAppJavaScriptMessageInfo.self, from: bodyData)
                handleBridgeMessage(responseJson: responseJson)
            }
    }

    func handleBridgeMessage(responseJson: MiniAppJavaScriptMessageInfo?) {
        guard let actionCommand = responseJson?.action, !actionCommand.isEmpty,
            let callbackId = responseJson?.id, !callbackId.isEmpty else {
            executeJavaScriptCallback(responseStatus: .onError, messageId: "", response: MiniAppJavaScriptError.unexpectedMessageFormat.rawValue)
            return
        }
        handleActionCommand(action: MiniAppJSActionCommand(rawValue: actionCommand)!, callbackId: callbackId)
    }

    func handleActionCommand(action: MiniAppJSActionCommand, callbackId: String) {
        switch action {
        case .getUniqueId:
            sendUniqueId(messageId: callbackId)
        }
    }

    func sendUniqueId(messageId: String) {
        guard let uniqueId = hostAppMessageDelegate?.getUniqueId(), !uniqueId.isEmpty else {
            executeJavaScriptCallback(responseStatus: .onError, messageId: messageId, response: MiniAppJavaScriptError.internalError.rawValue)
            return
        }
        executeJavaScriptCallback(responseStatus: .onSuccess, messageId: messageId, response: uniqueId)
    }

    func executeJavaScriptCallback(responseStatus: JavaScriptExecResult, messageId: String, response: String) {
        switch responseStatus {
        case .onSuccess:
            delegate?.didRecieveScriptMessageResponse(messageId: messageId, response: response)
        case .onError:
            delegate?.didRecieveScriptMessageError(messageId: messageId, errorMessage: response)
        }
    }
}
