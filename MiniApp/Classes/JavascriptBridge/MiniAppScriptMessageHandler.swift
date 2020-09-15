import Foundation
import WebKit
import CoreLocation

protocol MiniAppCallbackProtocol: AnyObject {
    func didReceiveScriptMessageResponse(messageId: String, response: String)
    func didReceiveScriptMessageError(messageId: String, errorMessage: String)
}

internal class MiniAppScriptMessageHandler: NSObject, WKScriptMessageHandler {

    var locationManager: LocationManager?
    weak var delegate: MiniAppCallbackProtocol?
    weak var hostAppMessageDelegate: MiniAppMessageProtocol?
    var miniAppId: String
    var userAlreadyRespondedRequestList = [MASDKCustomPermissionModel]()
    var cachedUnknownCustomPermissionRequest = [MiniAppCustomPermissionsListResponse]()
    var miniAppKeyStore = MiniAppKeyChain()

    init(delegate: MiniAppCallbackProtocol, hostAppMessageDelegate: MiniAppMessageProtocol, miniAppId: String) {
        self.delegate = delegate
        self.hostAppMessageDelegate = hostAppMessageDelegate
        self.miniAppId = miniAppId
        super.init()
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if let messageBody = message.body as? String {
                let bodyData: Data = messageBody.data(using: .utf8)!
                let responseJson = ResponseDecoder.decode(decodeType: MiniAppJavaScriptMessageInfo.self, data: bodyData)
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
        case .getCurrentPosition:
            locationManager = LocationManager(enableHighAccuracy: requestParam?.locationOptions?.enableHighAccuracy ?? false)
            getCurrentPosition(callbackId: callbackId)
        case .requestCustomPermissions:
            requestCustomPermissions(requestParam: requestParam, callbackId: callbackId)
        case .shareInfo:
            shareContent(requestParam: requestParam, callbackId: callbackId)
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
        guard let requestPermissionType = MiniAppPermissionType(rawValue: requestParamValue) else {
            executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: MiniAppJavaScriptError.invalidPermissionType.rawValue)
            return
        }

        switch requestPermissionType {
        case .location:
            getPermissionResult(requestPermissionType: requestPermissionType, callbackId: callbackId)
        }
    }

    func getPermissionResult(requestPermissionType: MiniAppPermissionType, callbackId: String) {
        hostAppMessageDelegate?.requestPermission(permissionType: requestPermissionType) { (result) in
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

    func getCurrentPosition(callbackId: String) {

        self.executeJavaScriptCallback(responseStatus: .onSuccess, messageId: callbackId, response: getLocationInfo())
    }

    func getLocationInfo() -> String {
        return  "{\"coords\":{\"latitude\":\(locationManager?.location?.coordinate.latitude ?? 0)" +
        ",\"longitude\":\(locationManager?.location?.coordinate.longitude ?? 0)" +
        ", \"altitude\":\(locationManager?.location?.altitude ?? "null" as Any)" +
        ", \"altitudeAccuracy\":\(locationManager?.location?.verticalAccuracy ?? "null" as Any)" +
        ", \"accuracy\":\(locationManager?.location?.horizontalAccuracy ?? 0)" +
        ", \"speed\":\(locationManager?.location?.speed ?? "null" as Any)" +
        ", \"heading\":\(locationManager?.location?.course ?? "null" as Any)" +
        "}, \"timestamp\":\(Date().epochInMilliseconds)}"
    }

    func executeJavaScriptCallback(responseStatus: JavaScriptExecResult, messageId: String, response: String) {
        switch responseStatus {
        case .onSuccess:
            delegate?.didReceiveScriptMessageResponse(messageId: messageId, response: response)
        case .onError:
            delegate?.didReceiveScriptMessageError(messageId: messageId, errorMessage: response)
        }
    }

    func shareContent(requestParam: RequestParameters?, callbackId: String) {
        guard let requestParamValue = requestParam?.shareInfo else {
            executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: MiniAppJavaScriptError.invalidPermissionType.rawValue)
            return
        }
        if !requestParamValue.content.isEmpty {
            hostAppMessageDelegate?.shareContent(info: MiniAppShareContent(messageContent: requestParamValue.content)) { (result) in
                switch result {
                case .success:
                    self.executeJavaScriptCallback(responseStatus: .onSuccess, messageId: callbackId, response: "SUCCESS")
                case .failure(let error):
                    if !error.localizedDescription.isEmpty {
                        self.executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: error.localizedDescription)
                        return
                    }
                    self.executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: MiniAppPermissionResult.denied.localizedDescription)
                }
            }
        } else {
            self.executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: "Share content message is empty")
        }
    }
}

class LocationManager: NSObject {
    let manager: CLLocationManager
    let location: CLLocation?

    init(enableHighAccuracy: Bool) {
        manager = CLLocationManager()
        location = manager.location
        super.init()
        manager.desiredAccuracy = enableHighAccuracy ? kCLLocationAccuracyBest : kCLLocationAccuracyHundredMeters
    }
}
