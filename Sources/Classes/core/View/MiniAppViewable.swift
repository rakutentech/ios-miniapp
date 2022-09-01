import Foundation
import UIKit

/// Public protocol for MiniAppView
public protocol MiniAppViewable: UIView, MiniAppNavigationBarDelegate {

    /// Loads the MiniApp (getInfo, download etc) and initialized the webview.
    /// After load is complete it will display the loaded MiniApp or an error.
    ///
    /// - Parameters:
    ///     - fromCache: Load the MiniApp from Cache (default is false)
    ///     -  completion: Completes with an optional MiniAppWebView that will be added onto the View or throws an MASDKError
    func load(fromCache: Bool, completion: @escaping ((Result<Bool, MASDKError>) -> Void))

    /// Loads the MiniApp async (getInfo, download etc) and initialized the webview
    /// After load is complete it will display the loaded MiniApp or an error.
    ///
    /// - Parameters:
    ///     - fromCache: Load the MiniApp from Cache (default is false)
    /// - Returns: The MiniAppLoadStatus which indicates `loadAsync` was sucessful
    @discardableResult
    func loadAsync(fromCache: Bool) async throws -> MiniAppView.MiniAppLoadStatus

    /// Alert Info when closing the MiniApp
    ///
    var alertInfo: CloseAlertInfo? { get }

}

public extension MiniAppViewable {
    func load(fromCache: Bool = false, completion: @escaping ((Result<Bool, MASDKError>) -> Void)) {
        load(fromCache: fromCache, completion: completion)
    }

    @discardableResult
    func loadAsync(fromCache: Bool = false) async throws -> MiniAppView.MiniAppLoadStatus {
        try await loadAsync(fromCache: fromCache)
    }
}
