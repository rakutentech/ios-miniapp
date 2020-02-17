/// Mini App Public API methods
public class MiniApp: NSObject {

    /// Fetch the List of [MiniAppInfo] information.
    /// Error information will be returned if any problem while fetching from the backed
    ///
    /// - Parameters:
    ///     -   completionBlock: A block to be called when list of [MiniAppInfo] information is fetched. Completion blocks receives the following parameters
    ///         -   [MiniAppInfo]: List of [MiniAppInfo] information.
    ///         -   Error: Error details if fetching is failed.
    public class func list(completionHandler: @escaping (Result<[MiniAppInfo], Error>) -> Void) {
        return RealMiniApp.shared.listMiniApp(completionHandler: completionHandler)
    }

    /// Create a Mini App for the given mini app info object, Mini app will be downloaded and cached in local.
    ///
    /// - Parameters:
    ///   - appInfo: Mini App info object
    ///   - completionBlock: A block to be called on successful creation of [MiniAppView] or throws errors if any. Completion blocks receives the following parameters
    ///         -   MiniAppDisplayProtocol: Protocol that helps the hosting application to communicate with the displayer module of the mini app. More like an interface for host app
    ///                         to interact with View component of mini app.
    ///         -   Error: Error details if Mini App View creating is failed
    public class func create(appInfo: MiniAppInfo, completionHandler: @escaping (Result<MiniAppDisplayProtocol, Error>) -> Void) {
        return RealMiniApp.shared.createMiniApp(appInfo: appInfo, completionHandler: completionHandler)
    }
}
