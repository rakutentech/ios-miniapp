/// Mini App Public API methods
public class MiniApp: NSObject {
    private static let shared = MiniApp()
    private let realMiniApp = RealMiniApp()

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
    public func info(miniAppId: String, completionHandler: @escaping (Result<MiniAppInfo, Error>) -> Void) {
        if miniAppId.count == 0 {
            return completionHandler(.failure(NSError.invalidAppId()))
        }
        return realMiniApp.getMiniApp(miniAppId: miniAppId, completionHandler: completionHandler)
    }

    /// Create a Mini App for the given mini appId, Mini app will be downloaded and cached in local.
    ///
    /// - Parameters:
    ///   - appId: Mini AppId String value
    ///   - completionBlock: A block to be called on successful creation of [MiniAppView] or throws errors if any. Completion blocks receives the following parameters
    ///         -   MiniAppDisplayProtocol: Protocol that helps the hosting application to communicate with the displayer module of the mini app. More like an interface for host app
    ///                         to interact with View component of mini app.
    ///         -   Error: Error details if Mini App View creating is failed
    ///   - messageInterface: Protocol implemented by the user that helps to communicate between Mini App and native application
    public func create(appId: String, completionHandler: @escaping (Result<MiniAppDisplayProtocol, Error>) -> Void, messageInterface: MiniAppMessageProtocol) {
        return realMiniApp.createMiniApp(appId: appId, completionHandler: completionHandler, messageInterface: messageInterface)
    }

    /// Create a Mini App for the given mini app info object, Mini app will be downloaded and cached in local.
    ///
    /// - Parameters:
    ///   - appInfo: Mini App info object
    ///   - completionBlock: A block to be called on successful creation of [MiniAppView] or throws errors if any. Completion blocks receives the following parameters
    ///         -   MiniAppDisplayProtocol: Protocol that helps the hosting application to communicate with the displayer module of the mini app. More like an interface for host app
    ///                         to interact with View component of mini app.
    ///         -   Error: Error details if Mini App View creating is failed
    ///   - messageInterface: Protocol implemented by the user that helps to communicate between Mini App and native application
    @available(*, deprecated,
    message:"Since version 2.0, you can create a Mini app view using just the mini app id",
    renamed: "create(appId:completionHandler:messageInterface:)")
    public func create(appInfo: MiniAppInfo, completionHandler: @escaping (Result<MiniAppDisplayProtocol, Error>) -> Void, messageInterface: MiniAppMessageProtocol) {
        return realMiniApp.createMiniApp(appInfo: appInfo, completionHandler: completionHandler, messageInterface: messageInterface)
    }

    /// Create a Mini App for the given mini app info object, Mini app will be downloaded and cached in local.
    ///
    /// - Parameters:
    ///   - appInfo: Mini App info object
    ///   - completionBlock: A block to be called on successful creation of [MiniAppView] or throws errors if any. Completion blocks receives the following parameters
    ///         -   MiniAppDisplayProtocol: Protocol that helps the hosting application to communicate with the displayer module of the mini app. More like an interface for host app
    ///                         to interact with View component of mini app.
    ///         -   Error: Error details if Mini App View creating is failed
    @available(*, deprecated,
    message:"Since version 1.1, you now need a MiniAppMessageProtocol that helps to communicate between Mini App and native application",
    renamed: "create(appInfo:completionHandler:messageInterface:)")
    public func create(appInfo: MiniAppInfo, completionHandler: @escaping (Result<MiniAppDisplayProtocol, Error>) -> Void) {
        return realMiniApp.createMiniApp(appInfo: appInfo, completionHandler: completionHandler)
    }
}
