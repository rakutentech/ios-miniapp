import Foundation
import WebKit

protocol MiniAppCallbackProtocol: AnyObject {
    func didReceiveScriptMessageResponse(messageId: String, response: String)
    func didReceiveScriptMessageError(messageId: String, errorMessage: String)
}

internal class MiniAppScriptMessageHandler: NSObject, WKScriptMessageHandler {

    weak var delegate: MiniAppCallbackProtocol?
    weak var hostAppMessageDelegate: MiniAppMessageProtocol?

    init(delegate: MiniAppCallbackProtocol, hostAppMessageDelegate: MiniAppMessageProtocol) {
        self.delegate = delegate
        self.hostAppMessageDelegate = hostAppMessageDelegate
        super.init()
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
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
        let requestParam = responseJson?.param ?? nil
        handleActionCommand(action: MiniAppJSActionCommand(rawValue: actionCommand)!, requestParam: requestParam, callbackId: callbackId)
    }

    func handleActionCommand(action: MiniAppJSActionCommand, requestParam: RequestParameters?, callbackId: String) {
        switch action {
        case .getUniqueId:
            sendUniqueId(messageId: callbackId)
        case .requestPermission:
            requestPermission(requestParam: requestParam, callbackId: callbackId)
        }
    }

    func sendUniqueId(messageId: String) {
        guard let uniqueId = hostAppMessageDelegate?.getUniqueId(), !uniqueId.isEmpty else {
            executeJavaScriptCallback(responseStatus: .onError, messageId: messageId, response: MiniAppJavaScriptError.internalError.rawValue)
            return
        }
        executeJavaScriptCallback(responseStatus: .onSuccess, messageId: messageId, response: uniqueId)
    }

    func requestPermission(requestParam: RequestParameters?, callbackId: String) {
        guard let requestParamValue = requestParam?.permission else {
            executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: MiniAppJavaScriptError.invalidPermissionType.rawValue)
            return
        }
        let requestPermissionType = MiniAppPermissionType(rawValue: requestParamValue)

        switch requestPermissionType {
        case .location:
            getPermissionResult(requestParam: requestParamValue, callbackId: callbackId)
        default:
            executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: MiniAppJavaScriptError.invalidPermissionType.rawValue)
        }
    }

    func getPermissionResult(requestParam: String, callbackId: String) {
        hostAppMessageDelegate?.requestPermission(permissionType: MiniAppPermissionType(rawValue: requestParam)!) { (result) in
            switch result {
            case .success:
                self.executeJavaScriptCallback(responseStatus: .onSuccess, messageId: callbackId, response: "Allowed")
            case .failure(let error):
                if !error.localizedDescription.isEmpty {
                    self.executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: error.localizedDescription)
                    return
                }
                self.executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: MiniAppPermissionResult.denied.localizedDescription)
            }
        }
    }

    func executeJavaScriptCallback(responseStatus: JavaScriptExecResult, messageId: String, response: String) {
        switch responseStatus {
        case .onSuccess:
            delegate?.didReceiveScriptMessageResponse(messageId: messageId, response: response)
        case .onError:
            delegate?.didReceiveScriptMessageError(messageId: messageId, errorMessage: response)
        }
    }
}
