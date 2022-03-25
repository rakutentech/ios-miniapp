enum Constants {
    static let miniAppSchemePrefix = "mscheme."
    static let rootFileName = "index.html"
    enum JavaScript {
        static let interfaceName = "MiniAppiOS"
        static let logHandler = "MiniAppLogging"
        static let successCallback = "MiniAppBridge.execSuccessCallback"
        static let errorCallback = "MiniAppBridge.execErrorCallback"
        static let eventCallback = "MiniAppBridge.execCustomEventsCallback"
        static let keyboardEventCallback = "MiniAppBridge.execKeyboardEventsCallback"
    }
}

/// Type alias for Download Lsit permissions pair
public typealias MASDKDownloadedListPermissionsPair = [(MiniAppInfo, [MASDKCustomPermissionModel])]

let offlineErrorCodeList: [Int] = [NSURLErrorNotConnectedToInternet, NSURLErrorTimedOut]
