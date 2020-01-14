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

    /// Create a Mini App for the given appId. Mini app will be downloaded and cached in local.
    ///
    /// - Parameters:
    ///   - appId: Unique Application Id of Mini App
    ///   - completionBlock: A block to be called on successful creation of [MiniAppView] or throws errors if any. Completion blocks receives the following parameters
    ///         -   [MiniAppView]: Mini App View placeholder that hosts the Mini App
    ///         -   Error: Error details if Mini App View creating is failed
    public class func create(appId: String, completionHandler: @escaping (Result<MiniAppView, Error>) -> Void) {
        return RealMiniApp.shared.createMiniApp(appId: appId, completionHandler: completionHandler)
    }
}
