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
    
    /// Initiates MiniApp SDK using the default config settings as defined in Info.plist.
    /// A MiniAppSdkConfig object can be provided to override this configuration
    ///
    /// - Parameters:
    ///     -   settings: A MiniAppSdkConfig object containing values to override default config settings.
    public class func configure(with settings: MiniAppSdkConfig? = nil){
        shared(with:settings).initialLaunchConfig()
    }

    /// Fetch the List of [MiniAppInfo] information.
    /// Error information will be returned if any problem while fetching from the backed
    ///
    /// - Parameters:
    ///     -   completionHandler: A block to be called when list of [MiniAppInfo] information is fetched. Completion blocks receives the following parameters
    ///         -   [MiniAppInfo]: List of [MiniAppInfo] information.
    ///         -   Error: Error details if fetching is failed.
    public func list(completionHandler: @escaping (Result<[MiniAppInfo], MASDKError>) -> Void) {
        return realMiniApp.listMiniApp(completionHandler: completionHandler)
    }

    /// Fetch the MiniAppInfo information for a given MiniApp id.
    ///
    /// - Parameters:
    ///     -   miniAppId: the identifier string of the Mini App you want information
    ///     -   completionHandler: A block to be called when MiniAppInfo information is fetched. Completion blocks receives the following parameters
    ///         -   MiniAppInfo: MiniAppInfo information.
    ///         -   Error: Error details if fetching is failed.
    public func info(miniAppId: String, miniAppVersion: String? = nil, completionHandler: @escaping (Result<MiniAppInfo, MASDKError>) -> Void) {
        if miniAppId.count == 0 {
            return completionHandler(.failure(.invalidAppId))
        }
        return realMiniApp.getMiniApp(miniAppId: miniAppId, miniAppVersion: miniAppVersion, completionHandler: completionHandler)
    }

    /// Create a Mini App for the given mini appId, Mini app will be downloaded and cached in local.
    ///
    /// - Parameters:
    ///   - appId: Mini AppId String value
    ///   - version: optional Mini App version String value. If omitted the modt recent one is picked
    ///   - completionHandler: A block to be called on successful creation of [MiniAppView] or throws errors if any. Completion blocks receives the following parameters
    ///         -   MiniAppDisplayProtocol: Protocol that helps the hosting application to communicate with the displayer module of the mini app. More like an interface for host app
    ///                         to interact with View component of mini app.
    ///         -   Error: Error details if Mini App View creating is failed
    ///   - messageInterface: Protocol implemented by the user that helps to communicate between Mini App and native application
    public func create(appId: String, version: String? = nil, completionHandler: @escaping (Result<MiniAppDisplayProtocol, MASDKError>) -> Void, messageInterface: MiniAppMessageDelegate) {
        return realMiniApp.createMiniApp(appId: appId, version: version, completionHandler: completionHandler, messageInterface: messageInterface)
    }

    /// Cache the Custom permissions status for a given MiniApp ID
    /// - Parameters:
    ///   - appId: Mini AppId String value
    ///   - permissionList: List of MASDKCustomPermissionModel class that contains the MiniAppCustomPermissionType and MiniAppCustomPermissionGrantedStatus
    public func setCustomPermissions(forMiniApp appId: String, permissionList: [MASDKCustomPermissionModel]) {
        return realMiniApp.storeCustomPermissions(forMiniApp: appId, permissionList: permissionList)
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

    /// Creates a Mini App for the given mini app info object, Mini app will be downloaded and cached in local.
    /// This method should only be used in "Preview Mode".
    ///
    /// - Parameters:
    ///   - appInfo: Mini App info object
    ///   - completionHandler: A block to be called on successful creation of [MiniAppView] or throws errors if any. Completion blocks receives the following parameters
    ///         -   MiniAppDisplayProtocol: Protocol that helps the hosting application to communicate with the displayer module of the mini app. More like an interface for host app
    ///                         to interact with View component of mini app.
    ///         -   Error: Error details if Mini App View creating is failed
    ///   - messageInterface: Protocol implemented by the user that helps to communicate between Mini App and native application
    public func create(appInfo: MiniAppInfo, completionHandler: @escaping (Result<MiniAppDisplayProtocol, Error>) -> Void, messageInterface: MiniAppMessageDelegate) {
        return realMiniApp.createMiniApp(appInfo: appInfo, completionHandler: completionHandler, messageInterface: messageInterface)
    }

    @available(*, deprecated,
    message:"Use MASDKError instead of Error in your completionHandler.",
    renamed: "list(completionHandler:)")
    public func list<T>(completionHandler: @escaping (Result<[MiniAppInfo], T>) -> Void) where T: Error {
        return self.list { (result) in
            switch result {
            case .success(let responseData):
                completionHandler(.success(responseData))
            case .failure(let error):
                // swiftlint:disable force_cast
                completionHandler(.failure(error as! T))
            }
        }
    }

    @available(*, deprecated,
    message:"Use MASDKError instead of Error in your completionHandler.",
    renamed: "info(miniAppId:completionHandler:)")
    public func info<T>(miniAppId: String, completionHandler: @escaping (Result<MiniAppInfo, T>) -> Void) where T: Error {
        self.info(miniAppId: miniAppId) { (result) in
                switch result {
                case .success(let responseData):
                    completionHandler(.success(responseData))
                case .failure(let error):
                    // swiftlint:disable force_cast
                    completionHandler(.failure(error as! T))
            }
        }
    }

    @available(*, deprecated,
    message:"Use MASDKError instead of Error in your completionHandler.",
    renamed: "create(appId:completionHandler:)")
    public func create<T>(appId: String, completionHandler: @escaping (Result<MiniAppDisplayProtocol, T>) -> Void, messageInterface: MiniAppMessageDelegate) where T: Error {
        let handler: (Result<MiniAppDisplayProtocol, MASDKError>) -> Void = { (result) in
                switch result {
                case .success(let responseData):
                    completionHandler(.success(responseData))
                case .failure(let error):
                    // swiftlint:disable force_cast
                    completionHandler(.failure(error as! T))
            }
        }
        return realMiniApp.createMiniApp(appId: appId, completionHandler: handler, messageInterface: messageInterface)
    }
}

// MARK: - Testing
public extension MiniApp {
    /// Creates a Mini App for the given url.
    /// Mini app will NOT be downloaded and cached in local, its content will be read directly from provided url.
    /// This should only be used for previewing a mini app from a local server.
    ///
    /// - Parameters:
    ///   - url: a HTTP url containing Mini App content
    ///   - errorHandler: A block to be called on unsuccessful initial load of Mini App's web content. The handler block receives the following parameter
    ///         -   Error: Error details if Mini App's url content loading is failed, otherwise nil.
    /// - Returns: MiniAppDisplayProtocol: Protocol that helps the hosting application to communicate with the displayer module of the mini app. More like an interface for host app
    ///                         to interact with View component of mini app.
    func create(url: URL,
                errorHandler: @escaping (Error) -> Void,
                messageInterface: MiniAppMessageDelegate) -> MiniAppDisplayProtocol {
        return realMiniApp.createMiniApp(url: url,
                                         errorHandler: errorHandler,
                                         messageInterface: messageInterface)
    }
}

// MARK: - Internal
internal extension MiniApp {
    func initialLaunchConfig() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            MiniAppAnalytics.sendAnalytics(event:.host_launch)
        }
    }
}
