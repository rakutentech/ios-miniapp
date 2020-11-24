/// Mini App Public API methods
public class MiniApp: NSObject {
    private static let shared = MiniApp()
    private let realMiniApp = RealMiniApp()
    public static var MAOrientationLock: UIInterfaceOrientationMask = []

    /// Instance of MiniApp which uses the default config settings as defined in Info.plist.
    /// A MiniAppSdkConfig object can be provided to override this configuration
    ///
    /// - Parameters:
    ///     -   settings: A MiniAppSdkConfig object containing values to override default config settings.
    public class func shared(with settings: MiniAppSdkConfig? = nil, navigationSettings: MiniAppNavigationConfig? = nil) -> MiniApp {
        shared.realMiniApp.update(with: settings, navigationSettings: navigationSettings)
        return shared
    }

    /// Fetch the List of [MiniAppInfo] information.
    /// Error information will be returned if any problem while fetching from the backed
    ///
    /// - Parameters:
    ///     -   completionBlock: A block to be called when list of [MiniAppInfo] information is fetched. Completion blocks receives the following parameters
    ///         -   [MiniAppInfo]: List of [MiniAppInfo] information.
    ///         -   Error: Error details if fetching is failed.
    public func list(completionHandler: @escaping (Result<[MiniAppInfo], Error>) -> Void) {
        return realMiniApp.listMiniApp(completionHandler: completionHandler)
    }

    /// Fetch the MiniAppInfo information for a given MiniApp id.
    ///
    /// - Parameters:
    ///     -   miniAppId: the identifier string of the Mini App you want information
    ///     -   completionHandler: A block to be called when MiniAppInfo information is fetched. Completion blocks receives the following parameters
    ///         -   MiniAppInfo: MiniAppInfo information.
    ///         -   Error: Error details if fetching is failed.
    public func info(miniAppId: String, miniAppVersion: String? = nil, completionHandler: @escaping (Result<MiniAppInfo, Error>) -> Void) {
        if miniAppId.count == 0 {
            return completionHandler(.failure(NSError.invalidAppId()))
        }
        return realMiniApp.getMiniApp(miniAppId: miniAppId, miniAppVersion: miniAppVersion, completionHandler: completionHandler)
    }

    /// Create a Mini App for the given mini appId, Mini app will be downloaded and cached in local.
    ///
    /// - Parameters:
    ///   - appId: Mini AppId String value
    ///   - version: optional Mini App version String value. If omitted the modt recent one is picked
    ///   - completionBlock: A block to be called on successful creation of [MiniAppView] or throws errors if any. Completion blocks receives the following parameters
    ///         -   MiniAppDisplayProtocol: Protocol that helps the hosting application to communicate with the displayer module of the mini app. More like an interface for host app
    ///                         to interact with View component of mini app.
    ///         -   Error: Error details if Mini App View creating is failed
    ///   - messageInterface: Protocol implemented by the user that helps to communicate between Mini App and native application
    public func create(appId: String, version: String? = nil, completionHandler: @escaping (Result<MiniAppDisplayProtocol, Error>) -> Void, messageInterface: MiniAppMessageDelegate) {
        return realMiniApp.createMiniApp(appId: appId, version: version, completionHandler: completionHandler, messageInterface: messageInterface)
    }

    /// Cache the Custom permissions status for a given MiniApp ID
    /// - Parameters:
    ///   - appId: Mini AppId String value
    ///   - permissionList: List of MASDKCustomPermissionModel class that contains the MiniAppCustomPermissionType and MiniAppCustomPermissionGrantedStatus
    public func setCustomPermissions(forMiniApp appId: String, permissionList: [MASDKCustomPermissionModel]) {
        if !appId.isEmpty {
            return realMiniApp.storeCustomPermissions(forMiniApp: appId, permissionList: permissionList)
        }
    }

    /// Get the list of supported Custom permissions and its status for a given Mini app ID
    /// - Parameter appId: Mini AppId String value
    /// - Returns: List of MASDKCustomPermissionModel that contains the details of every custom permission type, status and description.
    public func getCustomPermissions(forMiniApp appId: String) -> [MASDKCustomPermissionModel] {
        if !appId.isEmpty {
            return realMiniApp.retrieveCustomPermissions(forMiniApp: appId)
        }
        return []
    }

    /// Gets the list of downloaded Mini apps info and associated custom permissions status
    /// - Returns:Dictionary of MiniAppInfo and respective custom permissions info
    public func listDownloadedWithCustomPermissions() -> [(MiniAppInfo, [MASDKCustomPermissionModel])] {
        return realMiniApp.getDownloadedListWithCustomPermissions()
    }

//    public func getCustomPermissionsManageList

    /// Creates a Mini App for the given mini app info object, Mini app will be downloaded and cached in local.
    /// This method should only be used in "Preview Mode".
    ///
    /// - Parameters:
    ///   - appInfo: Mini App info object
    ///   - completionBlock: A block to be called on successful creation of [MiniAppView] or throws errors if any. Completion blocks receives the following parameters
    ///         -   MiniAppDisplayProtocol: Protocol that helps the hosting application to communicate with the displayer module of the mini app. More like an interface for host app
    ///                         to interact with View component of mini app.
    ///         -   Error: Error details if Mini App View creating is failed
    ///   - messageInterface: Protocol implemented by the user that helps to communicate between Mini App and native application
    public func create(appInfo: MiniAppInfo, completionHandler: @escaping (Result<MiniAppDisplayProtocol, Error>) -> Void, messageInterface: MiniAppMessageDelegate) {
        return realMiniApp.createMiniApp(appInfo: appInfo, completionHandler: completionHandler, messageInterface: messageInterface)
    }
}
