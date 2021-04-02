struct Constants {
    static let miniAppSchemePrefix = "mscheme."
    static let rootFileName = "index.html"
    static let javascriptInterfaceName = "MiniAppiOS"
    static let javascriptSuccessCallback = "MiniAppBridge.execSuccessCallback"
    static let javascriptErrorCallback = "MiniAppBridge.execErrorCallback"
}

public typealias MASDKDownloadedListPermissionsPair = [(MiniAppInfo, [MASDKCustomPermissionModel])]

let offlineErrorCodeList: [Int] = [NSURLErrorNotConnectedToInternet, NSURLErrorTimedOut]
