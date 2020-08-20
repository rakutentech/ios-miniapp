extension MiniAppScriptMessageHandler {
    func requestCustomPermissions(requestParam: RequestParameters?, callbackId: String) {
        guard let requestParamValue = requestParam?.permission else {
            executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: MiniAppJavaScriptError.invalidPermissionType.rawValue)
            return
        }

        guard let permissionRequestModelList = prepareCustomPermissionModelList(
            permissionList: requestParamValue,
            permissionDescription: requestParam?.permissionDescription),
            permissionRequestModelList.count > 0 else {
            executeJavaScriptCallback(responseStatus: .onError, messageId: callbackId, response: MiniAppJavaScriptError.invalidPermissionType.rawValue)
            return
        }
        getCustomPermissionResult(customPermissionRequestList: permissionRequestModelList, callbackId: callbackId)
    }

    func prepareCustomPermissionModelList(permissionList: [String], permissionDescription: String?) -> [MASDKCustomPermissionModel]? {
        var customPermissionRequestList: [MASDKCustomPermissionModel] = []
        permissionList.forEach {
            guard let permissionType = MiniAppCustomPermissionType(rawValue: $0) else {
                return
            }
            customPermissionRequestList.append(MASDKCustomPermissionModel(permissionName: permissionType, permissionRequestDescription: permissionDescription))
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
        let responseDict = Dictionary(result.map { ($0.permissionName.title, $0.isPermissionGranted) }) { first, _ in first }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: responseDict, options: .prettyPrinted) else {
            return
        }
        guard let jsonDataString = String(data: jsonData, encoding: .utf8) else {
            return
        }
        self.executeJavaScriptCallback(responseStatus: .onSuccess, messageId: callbackId, response: jsonDataString)
     }
}

/// MASDKCustomPermissionModel helps to communicate with the Host app back and forth when Custom Permissions are requested by a Mini App.
/// When Custom Permissions received from Mini app, this class is used by SDK to define the type of custom permissions that is requested and
/// the same is returned by Host app with isPermissionGranted values updated (Value returned after user responded to the list of permissions)
public class MASDKCustomPermissionModel {
    public var permissionName: MiniAppCustomPermissionType
    public var isPermissionGranted: MiniAppCustomPermissionResult
    public var permissionDescription: String?

    init(permissionName: MiniAppCustomPermissionType, isPermissionGranted: MiniAppCustomPermissionResult = .notDetermined, permissionRequestDescription: String? = "") {
        self.permissionName = permissionName
        self.isPermissionGranted = isPermissionGranted
        self.permissionDescription = permissionRequestDescription
    }
}
