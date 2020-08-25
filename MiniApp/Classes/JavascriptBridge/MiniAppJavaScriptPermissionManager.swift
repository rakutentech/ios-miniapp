extension MiniAppScriptMessageHandler {
    func requestCustomPermissions(requestParam: RequestParameters?, callbackId: String) {
        guard let requestParamValue = requestParam?.customPermissions else {
            executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: MiniAppJavaScriptError.invalidPermissionType.rawValue)
            return
        }

        guard let permissionRequestModelList = prepareCustomPermissionModelList(
            permissionList: requestParamValue),
            permissionRequestModelList.count > 0 else {
            executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: MiniAppJavaScriptError.invalidPermissionType.rawValue)
            return
        }
        getCustomPermissionResult(customPermissionRequestList: permissionRequestModelList, callbackId: callbackId)
    }

    func prepareCustomPermissionModelList(permissionList: [CustomPermissions]) -> [MASDKCustomPermissionModel]? {
        var customPermissionRequestList: [MASDKCustomPermissionModel] = []
        permissionList.forEach {
            guard let permissionType = MiniAppCustomPermissionType(rawValue: $0.name ?? "") else {
                return
            }
            customPermissionRequestList.append(MASDKCustomPermissionModel(permissionName: permissionType, permissionRequestDescription: $0.description))
        }
        return customPermissionRequestList
    }

    func getCustomPermissionResult(customPermissionRequestList: [MASDKCustomPermissionModel], callbackId: String) {
        hostAppMessageDelegate?.requestCustomPermissions(permissions: customPermissionRequestList) { (result) in
           switch result {
           case .success(let result):
                self.sendCustomPermissionsJsonResponse(result: result, callbackId: callbackId)
           case .failure(let error):
               if !error.localizedDescription.isEmpty {
                   self.executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: error.localizedDescription)
                   return
               }
               self.executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: MiniAppPermissionResult.denied.localizedDescription)
           }
        }
    }

    func sendCustomPermissionsJsonResponse(result: [MASDKCustomPermissionModel], callbackId: String) {
        guard let responseString = getSuccessResponseJson(result: result) else {
            self.executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: MiniAppPermissionResult.denied.localizedDescription)
            return
        }
        self.executeJavaScriptCallback(responseStatus: .onSuccess, messageId: callbackId, response: responseString)
    }

    func getSuccessResponseJson(result: [MASDKCustomPermissionModel]) -> String? {
        var permissionListResponse = [MiniAppCustomPermissionsListResponse]()
        result.forEach {
            permissionListResponse.append(MiniAppCustomPermissionsListResponse(name: $0.permissionName.rawValue, isGranted: $0.isPermissionGranted.rawValue))
        }
        if permissionListResponse.count > 0 {
            let responseObject = MiniAppCustomPermissionsResponse(permissions: permissionListResponse)
            do {
                let jsonData = try JSONEncoder().encode(responseObject)
                return String(data: jsonData, encoding: .utf8)!
            } catch let error {
                print(error)
                return nil
            }
        }
        return nil
    }
}

/// MASDKCustomPermissionModel helps to communicate with the Host app back and forth when Custom Permissions are requested by a Mini App.
/// When Custom Permissions received from Mini app, this class is used by SDK to define the type of custom permissions that is requested and
/// the same is returned by Host app with isPermissionGranted values updated (Value returned after user responded to the list of permissions)
public class MASDKCustomPermissionModel: Codable {
    public var permissionName: MiniAppCustomPermissionType
    public var isPermissionGranted: MiniAppCustomPermissionGrantedStatus
    public var permissionDescription: String?

    init(permissionName: MiniAppCustomPermissionType, isPermissionGranted: MiniAppCustomPermissionGrantedStatus = .allowed, permissionRequestDescription: String? = "") {
        self.permissionName = permissionName
        self.isPermissionGranted = isPermissionGranted
        self.permissionDescription = permissionRequestDescription
    }
}
