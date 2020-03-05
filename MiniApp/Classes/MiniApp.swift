/// Mini App Public API methods
public class MiniApp: NSObject {

    /// Fetch the List of [MiniAppInfo] information.
    /// Error information will be returned if any problem while fetching from the backed
    ///
    /// - Parameters:
    ///     -   config: on optional custom configuration to override default SDK parameters such as base URL, app ID, subsciption key or host app version
    ///     -   completionBlock: A block to be called when list of [MiniAppInfo] information is fetched. Completion blocks receives the following parameters
    ///         -   [MiniAppInfo]: List of [MiniAppInfo] information.
    ///         -   Error: Error details if fetching is failed.
    public class func list(config: MiniAppSdkConfig? = nil, completionHandler: @escaping (Result<[MiniAppInfo], Error>) -> Void) {
        return RealMiniApp.shared(with: config).listMiniApp(completionHandler: completionHandler)
    }

    /// Fetch the MiniAppInfo information for a given MiniApp id.
    ///
    /// - Parameters:
    ///     -   config: on optional custom configuration to override default SDK parameters such as base URL, app ID, subsciption key or host app version
    ///     -   miniAppId: the identifier string of the Mini App you want information
    ///     -   completionHandler: A block to be called when MiniAppInfo information is fetched. Completion blocks receives the following parameters
    ///         -   MiniAppInfo: MiniAppInfo information.
    ///         -   Error: Error details if fetching is failed.
    public class func info(config: MiniAppSdkConfig? = nil, miniAppId: String, completionHandler: @escaping (Result<MiniAppInfo, Error>) -> Void) {
        if miniAppId.count == 0 {
            return completionHandler(.failure(NSError.invalidAppId()))
        }
        return RealMiniApp.shared(with: config).getMiniApp(miniAppId: miniAppId, completionHandler: completionHandler)
    }

    /// Create a Mini App for the given mini app info object, Mini app will be downloaded and cached in local.
    ///
    /// - Parameters:
    ///   - config: on optional custom configuration to override default SDK parameters such as base URL, app ID, subsciption key or host app version
    ///   - appInfo: Mini App info object
    ///   - completionBlock: A block to be called on successful creation of [MiniAppView] or throws errors if any. Completion blocks receives the following parameters
    ///         -   MiniAppDisplayProtocol: Protocol that helps the hosting application to communicate with the displayer module of the mini app. More like an interface for host app
    ///                         to interact with View component of mini app.
    ///         -   Error: Error details if Mini App View creating is failed
    public class func create(config: MiniAppSdkConfig? = nil, appInfo: MiniAppInfo, completionHandler: @escaping (Result<MiniAppDisplayProtocol, Error>) -> Void) {
        return RealMiniApp.shared(with: config).createMiniApp(appInfo: appInfo, completionHandler: completionHandler)
    }
}

public class MiniAppSdkConfig {
    var baseUrl: String? {
        didSet(value) {
            if value?.count ?? 0 == 0 {
                baseUrl = nil
            }
        }
    }
    var rasAppId: String? {
        didSet(value) {
            if value?.count ?? 0 == 0 {
                rasAppId = nil
            }
        }
    }
    var subscriptionKey: String? {
        didSet(value) {
            if value?.count ?? 0 == 0 {
                subscriptionKey = nil
            }
        }
    }
    var hostAppVersion: String? {
        didSet(value) {
            if value?.count ?? 0 == 0 {
                hostAppVersion = nil
            }
        }
    }
    var key: String {
        return "\(baseUrl ?? "noBaseUrl")-\(rasAppId ?? "noRasAppId")-\(subscriptionKey ?? "noSubscriptionKey")-\(hostAppVersion ?? "noHostAppVersion")"
    }

    public init(baseUrl: String? = nil,
                rasAppId: String? = nil,
                subscriptionKey: String? = nil,
                hostAppVersion: String? = nil) {
        self.baseUrl = baseUrl?.count ?? 0 > 0 ? baseUrl : nil
        self.rasAppId = rasAppId?.count ?? 0 > 0 ? rasAppId : nil
        self.subscriptionKey = subscriptionKey?.count ?? 0 > 0 ? subscriptionKey : nil
        self.hostAppVersion = hostAppVersion?.count ?? 0 > 0 ? hostAppVersion : nil
    }
}
