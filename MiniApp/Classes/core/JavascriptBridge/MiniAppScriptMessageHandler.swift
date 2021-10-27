import Foundation
import WebKit
import CoreLocation

protocol MiniAppCallbackDelegate: AnyObject {
    func didReceiveScriptMessageResponse(messageId: String, response: String)
    func didReceiveScriptMessageError(messageId: String, errorMessage: String)
    func didReceiveEvent(_ event: MiniAppEvent, message: String)
}

// swiftlint:disable file_length
// swiftlint:disable type_body_length
internal class MiniAppScriptMessageHandler: NSObject, WKScriptMessageHandler {

    var locationManager: LocationManager?
    weak var delegate: MiniAppCallbackDelegate?
    weak var hostAppMessageDelegate: MiniAppMessageDelegate?
    weak var adsDelegate: MiniAppAdDisplayDelegate?
    var miniAppId: String
    var miniAppTitle: String
    var userAlreadyRespondedRequestList = [MASDKCustomPermissionModel]()
    var cachedUnknownCustomPermissionRequest = [MiniAppCustomPermissionsListResponse]()
    var permissionsNotAddedInManifest = [MASDKCustomPermissionModel]()
    var miniAppKeyStore = MiniAppPermissionsStorage()
    init(delegate: MiniAppCallbackDelegate, hostAppMessageDelegate: MiniAppMessageDelegate, adsDisplayer: MiniAppAdDisplayer?, miniAppId: String, miniAppTitle: String) {
        self.delegate = delegate
        self.hostAppMessageDelegate = hostAppMessageDelegate
        self.miniAppId = miniAppId
        self.miniAppTitle = miniAppTitle
        self.adsDelegate = adsDisplayer
        super.init()
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let messageBody = message.body as? String {
            MiniAppLogger.d(messageBody, "♨️️")
            if message.name == Constants.JavaScript.logHandler { return }
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
            updateLocation(callbackId: callbackId)
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
            fetchTokenDetails(callbackId: callbackId, for: requestParam)
        case .loadAd:
            loadRequestedAd(with: callbackId, for: requestParam)
        case .showAd:
            showRequestedAd(with: callbackId, for: requestParam)
        case .sendMessageToContact:
            sendMessageToContact(with: callbackId, parameters: requestParam)
        case .sendMessageToContactId:
            sendMessageToContactId(with: callbackId, parameters: requestParam)
        case .sendMessageToMultipleContacts:
            sendMessageToMultipleContacts(with: callbackId, parameters: requestParam)
        case .getPoints:
            fetchPoints(with: callbackId)
        case .getHostEnvironmentInfo:
            getHostEnvironmentInfo(with: callbackId)
        }
    }

    private func sendMessageToContact(with callBackId: String, parameters: RequestParameters?) {
        if let message = parameters?.messageToContact {
            hostAppMessageDelegate?.sendMessageToContact(message, completionHandler: { result in
                switch result {
                case .success(let contact):
                    let notEmptyId: String? = contact?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true ? nil : contact
                    self.messageSentSuccessResponse(callBackId: callBackId, notEmptyId: notEmptyId)
                case .failure(let error):
                    self.executeJavaScriptCallback(responseStatus: .onError, messageId: callBackId, response: error.localizedDescription)
                }
            })
        } else {
            executeJavaScriptCallback(responseStatus: .onError, messageId: callBackId, response: getMiniAppErrorMessage(MiniAppJavaScriptError.unexpectedMessageFormat))
        }
    }

    private func sendMessageToContactId(with callBackId: String, parameters: RequestParameters?) {
        if isUserAllowedPermission(customPermissionType: .sendMessage, callbackId: callBackId) {
            if let message = parameters?.messageToContact {
                if let contactId = parameters?.contactId {
                    hostAppMessageDelegate?.sendMessageToContactId(contactId, message: message) { result in
                        switch result {
                        case .success(let contact):
                            let notEmptyId: String? = contact?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true ? nil : contact
                            self.messageSentSuccessResponse(callBackId: callBackId, notEmptyId: notEmptyId)
                        case .failure(let error):
                            self.executeJavaScriptCallback(responseStatus: .onError, messageId: callBackId, response: error.localizedDescription)
                        }
                    }
                } else {
                    executeJavaScriptCallback(responseStatus: .onError, messageId: callBackId, response: getMiniAppErrorMessage(MiniAppJavaScriptError.unexpectedMessageFormat))
                }
            } else {
                executeJavaScriptCallback(responseStatus: .onError, messageId: callBackId, response: getMiniAppErrorMessage(MiniAppJavaScriptError.unexpectedMessageFormat))
            }
        }
    }

    private func sendMessageToMultipleContacts(with callBackId: String, parameters: RequestParameters?) {
        if let message = parameters?.messageToContact {
            hostAppMessageDelegate?.sendMessageToMultipleContacts(message, completionHandler: { result in
                switch result {
                case .success(let contactIds):
                    let notEmptyId: [String]? = contactIds?.isEmpty ?? true ? nil : contactIds
                    guard let data = try? JSONEncoder().encode(notEmptyId),
                          let response = String(data: data, encoding: .utf8) else {
                        return self.executeJavaScriptCallback(
                                responseStatus: .onError,
                                messageId: callBackId,
                                response: getMiniAppErrorMessage(MiniAppJavaScriptError.unexpectedMessageFormat))
                    }
                    self.executeJavaScriptCallback(responseStatus: .onSuccess, messageId: callBackId, response: response)
                case .failure(let error):
                    self.executeJavaScriptCallback(responseStatus: .onError, messageId: callBackId, response: error.localizedDescription)
                }
            })
        } else {
            executeJavaScriptCallback(responseStatus: .onError, messageId: callBackId, response: getMiniAppErrorMessage(MiniAppJavaScriptError.unexpectedMessageFormat))
        }
    }

    private func messageSentSuccessResponse(callBackId: String, notEmptyId: String?) {
        guard let data = try? JSONEncoder().encode(notEmptyId),
              let response = String(data: data, encoding: .utf8) else {
            return self.executeJavaScriptCallback(
                    responseStatus: .onError,
                    messageId: callBackId,
                    response: getMiniAppErrorMessage(MiniAppJavaScriptError.unexpectedMessageFormat))
        }
        self.executeJavaScriptCallback(responseStatus: .onSuccess, messageId: callBackId, response: response)
    }

    private func updateLocation(callbackId: String) {
        if isPermissionAllowedAlready(customPermissionType: .deviceLocation) {
            locationManager?.updateLocation {[weak self] result in
                switch result {
                case .success(let location):
                    self?.getCurrentPosition(callbackId: callbackId, location: location)
                case .failure(let error): self?.executeJavaScriptCallback(responseStatus: .onError,
                                                                          messageId: callbackId,
                                                                          response: prepareMAJSGeolocationError(error: error))
                }
            }
        } else {
            executeJavaScriptCallback(responseStatus: .onError,
                                      messageId: callbackId,
                                      response: prepareMAJSGeolocationError(error: .userDenied))
        }
    }

    func sendUniqueId(messageId: String) {
        hostAppMessageDelegate?.getUniqueId { (result) in
            switch result {
            case .success(let response):
                guard let uniqueId = response else {
                    self.executeJavaScriptCallback(responseStatus: .onError, messageId: messageId, response: getMiniAppErrorMessage(MiniAppErrorType.hostAppError))
                    return
                }
                self.executeJavaScriptCallback(responseStatus: .onSuccess, messageId: messageId, response: uniqueId)
            case .failure(let error):
                self.handleMASDKError(error: error, callbackId: messageId)
            }
        }
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

    func getCurrentPosition(callbackId: String, location: CLLocation?) {
        if isUserAllowedPermission(customPermissionType: .deviceLocation, callbackId: callbackId) {
            executeJavaScriptCallback(responseStatus: .onSuccess, messageId: callbackId, response: getLocationInfo(location: location))
        }
    }

    func getLocationInfo(location: CLLocation?) -> String {
        return "{\"coords\":{\"latitude\":\(location?.coordinate.latitude ?? 0)" +
            ",\"longitude\":\(location?.coordinate.longitude ?? 0)" +
            ", \"altitude\":\(location?.altitude ?? "null" as Any)" +
            ", \"altitudeAccuracy\":\(location?.verticalAccuracy ?? "null" as Any)" +
            ", \"accuracy\":\(location?.horizontalAccuracy ?? 0)" +
            ", \"speed\":\(location?.speed ?? "null" as Any)" +
            ", \"heading\":\(location?.course ?? "null" as Any)" +
            "}, \"timestamp\":\(Date().epochInMilliseconds)}"
    }

    func loadRequestedAd(with callbackId: String, for params: RequestParameters?) {
        guard let delegate = adsDelegate else {
            executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: NSError.miniAppAdProtocolError().localizedDescription)
            return
        }
        guard let params = params,
              let adTypeRaw = params.adType,
              let adType = MiniAppAdType(rawValue: adTypeRaw),
              let adId = params.adUnitId else {
            executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: MASDKAdsDisplayError.adIdError.localizedDescription)
            return
        }
        switch adType {
        case .interstitial:
            delegate.loadInterstitial(for: adId) { [weak self] result in
                self?.manageAdResult(result: result, callbackId: callbackId)
            }
        case .rewarded:
            delegate.loadRewarded(for: adId) { [weak self] result in
                self?.manageAdResult(result: result, callbackId: callbackId)
            }
        }
    }

    private func manageAdResult(result: Result<(), Error>, callbackId: String) {
        switch result {
        case .success:
            executeJavaScriptCallback(responseStatus: .onSuccess, messageId: callbackId, response: "Ad loaded")
        case .failure(let error):
            executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: error.localizedDescription)
        }
    }

    func showRequestedAd(with callbackId: String, for params: RequestParameters?) {
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

    func execCustomEventsCallback(with event: MiniAppEvent, message: String) {
        delegate?.didReceiveEvent(event, message: message)
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
        if isUserAllowedPermission(customPermissionType: .userName, callbackId: callbackId) {
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
        }
    }

    func fetchProfilePhoto(callbackId: String) {
        if isUserAllowedPermission(customPermissionType: .profilePhoto, callbackId: callbackId) {
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
        }
    }

    func fetchContacts(callbackId: String) {
        if isUserAllowedPermission(customPermissionType: .contactsList, callbackId: callbackId) {
            hostAppMessageDelegate?.getContacts { [self] result in
                switch result {
                case .success(let contactsList):
                    if let contactsListJson = ResponseEncoder.encode(data: contactsList) {
                        executeJavaScriptCallback(responseStatus: .onSuccess, messageId: callbackId, response: contactsListJson)
                    } else {
                        fallthrough
                    }
                case .failure:
                    executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: getMiniAppErrorMessage(MiniAppJavaScriptError.internalError))
                }
            }
        }
    }

    func isUserAllowedPermission(customPermissionType: MiniAppCustomPermissionType, callbackId: String) -> Bool {
        if isPermissionAllowedAlready(customPermissionType: customPermissionType) {
            return true
        } else {
            executeJavaScriptCallback(responseStatus: .onError,
                                      messageId: callbackId,
                                      response: getMiniAppErrorMessage(MASDKCustomPermissionError.userDenied))
            return false
        }
    }

    private func isPermissionAllowedAlready(customPermissionType: MiniAppCustomPermissionType) -> Bool {
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

    func fetchTokenDetails(callbackId: String, for requestParam: RequestParameters?) {
        if isUserAllowedPermission(customPermissionType: .accessToken, callbackId: callbackId) {
            guard var accessTokenPermission = MASDKAccessTokenScopes(audience: requestParam?.audience, scopes: []),
                  let accessTokenPermissions = MiniApp.shared().getDownloadedManifest(miniAppId: miniAppId)?.accessTokenPermissions,
                  accessTokenPermission.isPartOf(accessTokenPermissions) // we check that the Mini App manages scopes and that these scopes are included in the Manifest
                    else {
                return sendScopeError(callbackId: callbackId, type: .audienceNotSupportedError)
            }

            guard let scopes = requestParam?.scopes, accessTokenPermission.with(scopes: scopes).isPartOf(accessTokenPermissions) else { // we need a specific set of scopes
                return sendScopeError(callbackId: callbackId, type: .scopesNotSupportedError)
            }

            hostAppMessageDelegate?.getAccessToken(miniAppId: self.miniAppId, scopes: accessTokenPermission) { (result) in
                switch result {
                case .success(let responseMessage):
                    guard let jsonResponse = ResponseEncoder.encode(data: responseMessage) else {
                        self.executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: getMiniAppErrorMessage(MiniAppJavaScriptError.internalError))
                        return
                    }
                    self.executeJavaScriptCallback(responseStatus: .onSuccess, messageId: callbackId, response: jsonResponse)
                case .failure(let error):
                    self.executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: prepareMAJavascriptError(error))
                }
            }
        }
    }

    func fetchPoints(with callbackId: String) {
         if isUserAllowedPermission(customPermissionType: .points, callbackId: callbackId) {
            hostAppMessageDelegate?.getPoints { (result) in
                switch result {
                case .success(let response):
                    guard let encodedPoints = ResponseEncoder.encode(data: response) else {
                        self.executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: getMiniAppErrorMessage(MiniAppJavaScriptError.internalError))
                        return
                    }
                    self.executeJavaScriptCallback(responseStatus: .onSuccess, messageId: callbackId, response: encodedPoints)
                case .failure(let error):
                    self.executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: prepareMAJavascriptError(error))
                }
            }
        }
    }

    func getHostEnvironmentInfo(with callbackId: String) {
        hostAppMessageDelegate?.getHostEnvironmentInfo(completionHandler: { (result) in
            switch result {
            case .success(let response):
                guard let encodedResult = ResponseEncoder.encode(data: response) else {
                    self.executeJavaScriptCallback(
                        responseStatus: .onError,
                        messageId: callbackId,
                        response: prepareMAJavascriptError(MiniAppJavaScriptError.internalError)
                    )
                    return
                }
                self.executeJavaScriptCallback(
                    responseStatus: .onSuccess,
                    messageId: callbackId,
                    response: encodedResult
                )
            case .failure(let error):
                self.handleMASDKErrorWithJson(error: error, callbackId: callbackId)
            }
        })
    }

    private func sendScopeError(callbackId: String, type: MASDKAccessTokenError) {
        executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: prepareMAJavascriptError(type))
    }

    func handleMASDKError(error: MASDKError, callbackId: String) {
        if !error.localizedDescription.isEmpty {
            self.executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: error.localizedDescription)
            return
        }
        self.executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: getMiniAppErrorMessage(MiniAppErrorType.unknownError))
    }

    func handleMASDKErrorWithJson(error: MASDKError, callbackId: String) {
        if !error.localizedDescription.isEmpty {
            self.executeJavaScriptCallback(
                responseStatus: .onError,
                messageId: callbackId,
                response: error.localizedDescription
            )
            return
        }
        self.executeJavaScriptCallback(
            responseStatus: .onError,
            messageId: callbackId,
            response: prepareMAJavascriptError(MiniAppErrorType.unknownError)
        )
    }
}

class LocationManager: NSObject {
    let manager: CLLocationManager
    var locationListener: ((Result<CLLocation?, MAJSNaviGeolocationError>) -> Void)?

    init(enableHighAccuracy: Bool) {
        manager = CLLocationManager()
        super.init()
        manager.desiredAccuracy = enableHighAccuracy ? kCLLocationAccuracyBest : kCLLocationAccuracyHundredMeters
        manager.delegate = self
    }

    func updateLocation(result: @escaping (Result<CLLocation?, MAJSNaviGeolocationError>) -> Void) {
        if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            self.locationListener = result
            manager.startUpdatingLocation()
        } else {
            result(.failure(.devicePermissionDenied))
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationListener?(.success(locations[0]))
        manager.stopUpdatingLocation()
    }
}
