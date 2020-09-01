enum MiniAppJSActionCommand: String {
    case getUniqueId
    case requestPermission
    case getCurrentPosition
}

enum JavaScriptExecResult: String {
    case onSuccess
    case onError
}

enum MiniAppJavaScriptError: String {
    case internalError
    case unexpectedMessageFormat
    case invalidPermissionType
}

enum MiniAppSupportedSchemes: String {
    case tel
}

/// List of Device Permissions supported by the SDK that can be requested by a Mini app
public enum MiniAppPermissionType: String {
    /// Device Location permission type. Host app is expected to implement the logic only for requesting the location permission.
    case location
}

public enum MiniAppPermissionResult: Error {
    /// User has explicitly denied authorization
    case denied
    /// User has not yet made a choice
    case notDetermined
    /// Host app is not authorized to use location services
    case restricted
}

extension MiniAppPermissionResult: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .denied:
            return NSLocalizedString("Denied", comment: "Permission Error")
        case .notDetermined:
            return NSLocalizedString("NotDetermined", comment: "Permission Error")
        case .restricted:
            return NSLocalizedString("Restricted", comment: "Permission Error")
        }
    }
}
