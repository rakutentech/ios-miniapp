import Foundation
import WebKit
import CoreLocation

@available(*, deprecated, message: "protocol renamed to MiniAppCallbackDelegate")
typealias MiniAppCallbackProtocol = MiniAppCallbackDelegate

protocol MiniAppCallbackDelegate: AnyObject {
    func didReceiveScriptMessageResponse(messageId: String, response: String)
    func didReceiveScriptMessageError(messageId: String, errorMessage: String)
}

internal class MiniAppScriptMessageHandler: NSObject, WKScriptMessageHandler {

    var locationManager: LocationManager?
    weak var delegate: MiniAppCallbackDelegate?
    weak var hostAppMessageDelegate: MiniAppMessageDelegate?
    weak var adsDelegate: MiniAppAdDisplayDelegate?
    var miniAppId: String
    var miniAppTitle: String
    var userAlreadyRespondedRequestList = [MASDKCustomPermissionModel]()
    var cachedUnknownCustomPermissionRequest = [MiniAppCustomPermissionsListResponse]()
    var miniAppKeyStore = MiniAppKeyChain()

    init(delegate: MiniAppCallbackDelegate, hostAppMessageDelegate: MiniAppMessageDelegate, adsDelegate: MiniAppAdDisplayDelegate?, miniAppId: String, miniAppTitle: String) {
        self.delegate = delegate
        self.hostAppMessageDelegate = hostAppMessageDelegate
        self.miniAppId = miniAppId
        self.miniAppTitle = miniAppTitle
        self.adsDelegate = adsDelegate
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
            let callbackId = responseJson?.id, !callbackId.isEmpty, let requestAction = MiniAppJSActionCommand(rawValue: actionCommand) else {
                executeJavaScriptCallback(responseStatus: .onError, messageId: "", response: getMiniAppErrorMessage(MiniAppJavaScriptError.unexpectedMessageFormat))
                return
        }
        let requestParam = responseJson?.param ?? nil
        handleActionCommand(action: requestAction, requestParam: requestParam, callbackId: callbackId)
    }

    func handleActionCommand(action: MiniAppJSActionCommand, requestParam: RequestParameters?, callbackId: String) {
        switch action {
        case .getUniqueId:
            sendUniqueId(messageId: callbackId)
        case .requestPermission:
            requestDevicePermission(requestParam: requestParam, callbackId: callbackId)
        case .getCurrentPosition:
            locationManager = LocationManager(enableHighAccuracy: requestParam?.locationOptions?.enableHighAccuracy ?? false)
            getCurrentPosition(callbackId: callbackId)
        case .requestCustomPermissions:
            requestCustomPermissions(requestParam: requestParam, callbackId: callbackId)
        case .shareInfo:
            shareContent(requestParam: requestParam, callbackId: callbackId)
        case .getUserName:
            fetchUserName(callbackId: callbackId)
        case .getProfilePhoto:
            fetchProfilePhoto(callbackId: callbackId)
        case .getContacts:
            fetchContacts(callbackId: callbackId)
        case .setScreenOrientation:
            setScreenOrientation(requestParam: requestParam, callbackId: callbackId)
        case .getAccessToken:
            fetchTokenDetails(callbackId: callbackId)
        case .loadAd:
            loadRequestedAd(forParams: requestParam) { [weak self] result in
                switch result {
                case .success:
                    self?.executeJavaScriptCallback(responseStatus: .onSuccess, messageId: callbackId, response: "Ad loaded")
                case .failure(let error):
                    self?.executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: error.localizedDescription)
                }
            }
        case .showAd:
            showRequestedAd(callbackId: callbackId, params: requestParam)
        }

    }

    func loadRequestedAd(forParams params: RequestParameters?, onLoaded: @escaping (Result<Void, Error>) -> Void) {
        guard let delegate = adsDelegate else {
            return onLoaded(.failure(NSError.miniAppAdProtocoleError()))
        }
        guard let params = params,
              let adTypeRaw = params.adType,
              let adType = MiniAppAdType(rawValue: adTypeRaw),
              let adId = params.adUnitId else {
            return onLoaded(.failure(NSError.miniAppAdNotLoaded(message: MASDKAdsDisplayError.adIdError.localizedDescription)))
        }
        switch adType {
        case .interstitial:
            delegate.loadInterstitial(for: adId, onLoaded: onLoaded)
        case .rewarded:
            delegate.loadRewarded(for: adId, onLoaded: onLoaded)
        }
    }

    func sendUniqueId(messageId: String) {
        guard let uniqueId = hostAppMessageDelegate?.getUniqueId(), !uniqueId.isEmpty else {
            executeJavaScriptCallback(responseStatus: .onError, messageId: messageId, response: getMiniAppErrorMessage(MiniAppJavaScriptError.internalError))
            return
        }
        executeJavaScriptCallback(responseStatus: .onSuccess, messageId: messageId, response: uniqueId)
    }

    func requestDevicePermission(requestParam: RequestParameters?, callbackId: String) {
        guard let requestParamValue = requestParam?.permission else {
            executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: getMiniAppErrorMessage(MiniAppJavaScriptError.invalidPermissionType))
            return
        }
        guard let requestPermissionType = MiniAppDevicePermissionType(rawValue: requestParamValue) else {
            executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: getMiniAppErrorMessage(MiniAppJavaScriptError.invalidPermissionType))
            return
        }

        switch requestPermissionType {
        case .location:
            getPermissionResult(requestPermissionType: requestPermissionType, callbackId: callbackId)
        }
    }

    func getPermissionResult(requestPermissionType: MiniAppDevicePermissionType, callbackId: String) {
        hostAppMessageDelegate?.requestDevicePermission(permissionType: requestPermissionType) { (result) in
            switch result {
            case .success(let responseMessage):
                self.executeJavaScriptCallback(responseStatus: .onSuccess, messageId: callbackId, response: responseMessage.rawValue)
            case .failure(let error):
                self.executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: getMiniAppErrorMessage(error))
            }
        }
    }

    func getCurrentPosition(callbackId: String) {
        if isUserAllowedPermission(customPermissionType: MiniAppCustomPermissionType.deviceLocation) {
            executeJavaScriptCallback(responseStatus: .onSuccess, messageId: callbackId, response: getLocationInfo())
        } else {
            executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: getMiniAppErrorMessage(MASDKCustomPermissionError.userDenied))
        }
    }

    func getLocationInfo() -> String {
        return "{\"coords\":{\"latitude\":\(locationManager?.location?.coordinate.latitude ?? 0)" +
            ",\"longitude\":\(locationManager?.location?.coordinate.longitude ?? 0)" +
            ", \"altitude\":\(locationManager?.location?.altitude ?? "null" as Any)" +
            ", \"altitudeAccuracy\":\(locationManager?.location?.verticalAccuracy ?? "null" as Any)" +
            ", \"accuracy\":\(locationManager?.location?.horizontalAccuracy ?? 0)" +
            ", \"speed\":\(locationManager?.location?.speed ?? "null" as Any)" +
            ", \"heading\":\(locationManager?.location?.course ?? "null" as Any)" +
            "}, \"timestamp\":\(Date().epochInMilliseconds)}"
    }

    func showRequestedAd(callbackId: String, params: RequestParameters?) {
        guard let adTypeRaw = params?.adType,
              let adType = MiniAppAdType(rawValue: adTypeRaw),
              let adUnitId = params?.adUnitId else {
            executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: getMiniAppErrorMessage(MASDKAdsDisplayError.adIdError))
            return
        }

        switch adType {
        case .interstitial:
            showInterstitial(callbackId: callbackId, adUnitId: adUnitId)
        case .rewarded:
            showRewarded(callbackId: callbackId, adUnitId: adUnitId)
        }
    }

    func showInterstitial(callbackId: String, adUnitId: String) {
        if let adDelegate = adsDelegate {
            adDelegate.showInterstitial(for: adUnitId) { [weak self] result in
                switch result {
                case .success:
                    self?.executeJavaScriptCallback(responseStatus: .onSuccess, messageId: callbackId, response: "Ad loaded successfully")
                case .failure(let error):
                    self?.executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: error.localizedDescription)
                }
            }
        } else {
            executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: getMiniAppErrorMessage(MASDKAdsDisplayError.failedToConformToProtocol))
        }
    }

    func showRewarded(callbackId: String, adUnitId: String) {
        if let adDelegate = adsDelegate {
            adDelegate.showRewarded(for: adUnitId) { [weak self] result in
                switch result {
                case .success(let reward):
                    if let response = ResponseEncoder.encode(data: reward) {
                        self?.executeJavaScriptCallback(responseStatus: .onSuccess, messageId: callbackId, response: response)
                    } else {
                        self?.executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: getMiniAppErrorMessage(MiniAppJavaScriptError.internalError))
                    }
                case .failure(let error):
                    self?.executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: error.localizedDescription)
                }
            }
        } else {
            executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: getMiniAppErrorMessage(MASDKAdsDisplayError.failedToConformToProtocol))
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

    func shareContent(requestParam: RequestParameters?, callbackId: String) {
        guard let requestParamValue = requestParam?.shareInfo else {
            executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: MiniAppJavaScriptError.invalidPermissionType.rawValue)
            return
        }
        if !requestParamValue.content.isEmpty {
            let info = MiniAppShareContent(messageContent: requestParamValue.content)
            self.hostAppMessageDelegate?.shareContent(
                info: info) { (result) in
                self.manageShareResult(result, with: callbackId)
            }
        } else {
            self.executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: getMiniAppErrorMessage(MiniAppJavaScriptError.valueIsEmpty))
        }
    }

    func manageShareResult(_ result: Result<MASDKProtocolResponse, Error>, with callbackId: String) {
        switch result {
        case .success:
            self.executeJavaScriptCallback(responseStatus: .onSuccess, messageId: callbackId, response: "SUCCESS")
        case .failure(let error):
            if !error.localizedDescription.isEmpty {
                self.executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: error.localizedDescription)
                return
            }
            self.executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: getMiniAppErrorMessage(MiniAppErrorType.unknownError))
        }
    }

    func fetchUserName(callbackId: String) {
        if isUserAllowedPermission(customPermissionType: MiniAppCustomPermissionType.userName) {
            hostAppMessageDelegate?.getUserName { (result) in
                switch result {
                case .success(let response):
                    guard let userName = response else {
                        self.executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: getMiniAppErrorMessage(MiniAppErrorType.hostAppError))
                        return
                    }
                    self.executeJavaScriptCallback(responseStatus: .onSuccess, messageId: callbackId, response: userName)
                case .failure(let error):
                    self.handleMASDKError(error: error, callbackId: callbackId)
                }
            }
        } else {
            executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: getMiniAppErrorMessage(MASDKCustomPermissionError.userDenied))
        }
    }

    func fetchProfilePhoto(callbackId: String) {
        if isUserAllowedPermission(customPermissionType: MiniAppCustomPermissionType.profilePhoto) {
            hostAppMessageDelegate?.getProfilePhoto { (result) in
                switch result {
                case .success(let response):
                    guard let profilePhoto = response else {
                        self.executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: getMiniAppErrorMessage(MiniAppErrorType.hostAppError))
                        return
                    }
                    self.executeJavaScriptCallback(responseStatus: .onSuccess, messageId: callbackId, response: profilePhoto)
                case .failure(let error):
                    self.handleMASDKError(error: error, callbackId: callbackId)
                }
            }
        } else {
            executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: getMiniAppErrorMessage(MASDKCustomPermissionError.userDenied))
        }
    }

    func fetchContacts(callbackId: String) {
        if isUserAllowedPermission(customPermissionType: MiniAppCustomPermissionType.contactsList) {
            guard let contactList = ResponseEncoder.encode(data: hostAppMessageDelegate?.getContacts()) else {
                executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: getMiniAppErrorMessage(MiniAppJavaScriptError.internalError))
                return
            }
            executeJavaScriptCallback(responseStatus: .onSuccess, messageId: callbackId, response: contactList)
            return
        }
        executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: getMiniAppErrorMessage(MASDKCustomPermissionError.userDenied))
    }

    func isUserAllowedPermission(customPermissionType: MiniAppCustomPermissionType) -> Bool {
        let customPermission = self.miniAppKeyStore.getCustomPermissions(forMiniApp: self.miniAppId).filter { $0.permissionName == customPermissionType }
        if !customPermission.isEmpty {
            return customPermission[0].isPermissionGranted.boolValue
        } else {
            return false
        }
    }

    func setScreenOrientation(requestParam: RequestParameters?, callbackId: String) {
        guard let requestParamValue = requestParam?.action else {
            executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: getMiniAppErrorMessage(MiniAppJavaScriptError.unexpectedMessageFormat))
            return
        }
        if !requestParamValue.isEmpty {
            guard let info = MiniAppInterfaceOrientation(rawValue: requestParamValue) else {
                self.executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: getMiniAppErrorMessage(MiniAppJavaScriptError.unexpectedMessageFormat))
                return
            }
            MiniApp.MAOrientationLock = info.orientation
            UIViewController.attemptRotationToDeviceOrientation()
            executeJavaScriptCallback(responseStatus: .onSuccess, messageId: callbackId, response: MASDKProtocolResponse.success.rawValue)
        } else {
            self.executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: getMiniAppErrorMessage(MiniAppJavaScriptError.valueIsEmpty))
        }
    }

    func fetchTokenDetails(callbackId: String) {
        hostAppMessageDelegate?.getAccessToken(miniAppId: self.miniAppId) { (result) in
            switch result {
            case .success(let responseMessage):
                guard let jsonResponse = ResponseEncoder.encode(data: responseMessage) else {
                    self.executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: getMiniAppErrorMessage(MiniAppJavaScriptError.internalError))
                    return
                }
                self.executeJavaScriptCallback(responseStatus: .onSuccess, messageId: callbackId, response: jsonResponse)
            case .failure(let error):
                self.executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: getMiniAppErrorMessage(error))
            }
        }
    }

    func handleMASDKError(error: MASDKError, callbackId: String) {
        if !error.localizedDescription.isEmpty {
            self.executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: error.localizedDescription)
            return
        }
        self.executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: getMiniAppErrorMessage(MiniAppErrorType.unknownError))
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
