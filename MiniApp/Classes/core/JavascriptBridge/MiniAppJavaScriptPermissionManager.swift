extension MiniAppScriptMessageHandler {
    func requestCustomPermissions(requestParam: RequestParameters?, callbackId: String) {
        cachedUnknownCustomPermissionRequest.removeAll()
        permissionsNotAddedInManifest.removeAll()
        userAlreadyRespondedRequestList.removeAll()
        guard let requestParamValue = requestParam?.permissions else {
            executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: getMiniAppErrorMessage(MASDKCustomPermissionError.invalidCustomPermissionRequest))
            return
        }

        guard let miniAppPermissionRequestModelList = prepareCustomPermissionsRequestModelList(
            permissionList: requestParamValue),
            miniAppPermissionRequestModelList.count > 0 else {
                executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: getMiniAppErrorMessage(MASDKCustomPermissionError.invalidCustomPermissionsList))
                return
        }
        checkCustomPermissionsRequestStatusInCache(miniAppPermissionRequestModelList: miniAppPermissionRequestModelList, callbackId: callbackId)
    }

    func checkCustomPermissionsRequestStatusInCache(miniAppPermissionRequestModelList: [MASDKCustomPermissionModel], callbackId: String) {
        let cachedPermissionsList = self.miniAppKeyStore.getCustomPermissions(forMiniApp: self.miniAppId)

        let allowedList = cachedPermissionsList.filter {
            $0.isPermissionGranted == .allowed
        }

        userAlreadyRespondedRequestList = allowedList.filter {
            miniAppPermissionRequestModelList.contains($0)
        }

        var userNotRespondedRequestList = miniAppPermissionRequestModelList.filter {
            !allowedList.contains($0)
        }

        permissionsNotAddedInManifest = userNotRespondedRequestList.filter { !cachedPermissionsList.contains($0) }
        /// To make sure that only permissions mentioned in the manifest is allowed at run-time
        userNotRespondedRequestList = userNotRespondedRequestList.filter {
            cachedPermissionsList.contains($0)
        }

        if userNotRespondedRequestList.count > 0 {
            requestHostApp(customPermissionRequestList: userNotRespondedRequestList, callbackId: callbackId)
        } else {
            self.sendCachedSuccessResponse(result: userAlreadyRespondedRequestList, callbackId: callbackId)
        }
    }

    /// List of Custom permissions that is requested from MIniapp is changed to array of Model class (including name, description and status) and the same will be sent to Host app
    /// - Parameter permissionList: List of permissions request from the Mini app
    /// - Returns: List of MASDKCustomPermissionModel that contains the details of every permissions
    func prepareCustomPermissionsRequestModelList(permissionList: [MiniAppCustomPermissionsRequest]) -> [MASDKCustomPermissionModel]? {
        var customPermissionRequestList: [MASDKCustomPermissionModel] = []
        permissionList.forEach {
            guard let permissionType = MiniAppCustomPermissionType(rawValue: $0.name ?? "") else {
                cachedUnknownCustomPermissionRequest.append(
                    MiniAppCustomPermissionsListResponse(
                        name: $0.name ?? "UNKNOWN_REQUEST",
                        status:
                            MiniAppCustomPermissionGrantedStatus.permissionNotAvailable.rawValue))
                return
            }
            customPermissionRequestList.append(MASDKCustomPermissionModel(permissionName: permissionType, permissionRequestDescription: $0.description))
        }
        return customPermissionRequestList
    }

    /// Request Host app to implement requestCustomPermissions delegate to request Custom Permissions
    /// - Parameters:
    ///   - customPermissionRequestList: List of MASDKCustomPermissionModel which contains the meta info of every custom permission that is requested
    ///   - callbackId: Callback ID that is used to send success/error response back to Miniapp
    func requestHostApp(customPermissionRequestList: [MASDKCustomPermissionModel], callbackId: String) {
        hostAppMessageDelegate?.requestCustomPermissions(permissions: customPermissionRequestList, miniAppTitle: self.miniAppTitle) { (result) in
            switch result {
            case .success(let result):
                self.miniAppKeyStore.storeCustomPermissions(permissions: result, forMiniApp: self.miniAppId)
                self.sendCustomPermissionsJsonResponse(result: result, callbackId: callbackId)
            case .failure(let error):
                self.executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: getMiniAppErrorMessage(error))
            }
        }
    }

    /// Method used to prepare the custom MiniAppCustomPermissionsListResponse that is needed to send back to Mini app
    /// - Parameters:
    ///   - result: List of MASDKCustomPermissionModel that is responded by the user
    ///   - callbackId: callbackId used to send the success/failure response back
    func sendCachedSuccessResponse(result: [MASDKCustomPermissionModel], callbackId: String) {
        var permissionListResponse = [MiniAppCustomPermissionsListResponse]()
        result.forEach {
            permissionListResponse.append(MiniAppCustomPermissionsListResponse(name: $0.permissionName.rawValue, status: $0.isPermissionGranted.rawValue))
        }
        cachedUnknownCustomPermissionRequest.forEach {
            permissionListResponse.append($0)
        }

        permissionsNotAddedInManifest.forEach {
            permissionListResponse.append(MiniAppCustomPermissionsListResponse(name: $0.permissionName.rawValue, status: MiniAppCustomPermissionGrantedStatus.denied.rawValue))
        }

        sendSuccessResponse(result: permissionListResponse, callbackId: callbackId)
    }

    func sendCustomPermissionsJsonResponse(result: [MASDKCustomPermissionModel], callbackId: String) {
        sendSuccessResponse(result: retrieveAllPermissionsMiniAppRequested(result: result), callbackId: callbackId)
    }

    func sendSuccessResponse(result: [MiniAppCustomPermissionsListResponse], callbackId: String) {
        let responseString = getJsonSuccessResponse(result: result)
        self.executeJavaScriptCallback(responseStatus: .onSuccess, messageId: callbackId, response: responseString)
    }

    /// Accumulate All Permissions that is requested from a Mini app. Following items are appended in the list
    ///  - List of Permissions that is responded by the user
    ///  - List of permissions that is already responded by the user but the mini app added in the request list
    ///  - List of Unknown Permissions that is requested by the Mini app
    /// - Parameter result: List of Permissions that is responded by the user
    /// - Returns: [MiniAppCustomPermissionsListResponse] that will be used by the JSONEncoder
    func retrieveAllPermissionsMiniAppRequested(result: [MASDKCustomPermissionModel]) -> [MiniAppCustomPermissionsListResponse] {
        var permissionListResponse = [MiniAppCustomPermissionsListResponse]()
        result.forEach {
            permissionListResponse.append(MiniAppCustomPermissionsListResponse(name: $0.permissionName.rawValue, status: $0.isPermissionGranted.rawValue))
        }
        userAlreadyRespondedRequestList.forEach {
            permissionListResponse.append(MiniAppCustomPermissionsListResponse(name: $0.permissionName.rawValue, status: $0.isPermissionGranted.rawValue))
        }
        cachedUnknownCustomPermissionRequest.forEach {
            permissionListResponse.append($0)
        }
        permissionsNotAddedInManifest.forEach {
            permissionListResponse.append(MiniAppCustomPermissionsListResponse(name: $0.permissionName.rawValue, status: MiniAppCustomPermissionGrantedStatus.denied.rawValue))
        }
        return permissionListResponse
    }

    /// For a given [MiniAppCustomPermissionsListResponse], this method will use JSONEncoder to encode the [objects] to JSON string
    /// - Parameter result: [MiniAppCustomPermissionsListResponse] that contains the name and status of every permission that will be sent back to the Mini app as JSON
    /// - Returns: JSON Response string
    func getJsonSuccessResponse(result: [MiniAppCustomPermissionsListResponse]) -> String {
        let responseObject = MiniAppCustomPermissionsResponse(permissions: result)
        do {
            let jsonData = try JSONEncoder().encode(responseObject)
            return String(data: jsonData, encoding: .utf8)!
        } catch let error {
            return error.localizedDescription
        }
    }
}

/// MASDKCustomPermissionModel helps to communicate with the Host app back and forth when Custom Permissions are requested by a Mini App.
/// When Custom Permissions received from Mini app, this class is used by SDK to define the type of custom permissions that is requested and
/// the same is returned by Host app with isPermissionGranted values updated (Value returned after user responded to the list of permissions)
public class MASDKCustomPermissionModel: Codable, Hashable, Comparable {
    public static func < (lhs: MASDKCustomPermissionModel, rhs: MASDKCustomPermissionModel) -> Bool {
        lhs.permissionName.rawValue < rhs.permissionName.rawValue
    }

    /// Static func that will be used for Equatable
    public static func == (lhs: MASDKCustomPermissionModel, rhs: MASDKCustomPermissionModel) -> Bool {
        lhs.permissionName == rhs.permissionName
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(permissionName)
        hasher.combine(permissionDescription)
    }

    /// Name of the Custom permission that is requested
    public var permissionName: MiniAppCustomPermissionType
    /// Current status of the Custom permissions
    public var isPermissionGranted: MiniAppCustomPermissionGrantedStatus
    /// Description for the respective custom permission
    public var permissionDescription: String?

    init(permissionName: MiniAppCustomPermissionType, isPermissionGranted: MiniAppCustomPermissionGrantedStatus = .allowed, permissionRequestDescription: String? = "") {
        self.permissionName = permissionName
        self.isPermissionGranted = isPermissionGranted
        self.permissionDescription = permissionRequestDescription
    }
}
