import Foundation
import UIKit
import Combine

/// Public protocol for MiniAppView
public protocol MiniAppViewable: UIView, MiniAppNavigationBarDelegate {

    /// The state of the MiniApp (eg. loading, active, error)
    var state: PassthroughSubject<MiniAppViewState, Never> {get}

    /// ProgressView that can be displayed on top of MiniAppView
    /// When using the `UI` module `MiniAppProgressView` can be used as default
    var progressStateView: MiniAppProgressViewable? {get set}

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

    var enable3DTouch: Bool { get }

    func loadFromBundle(miniAppManifest: MiniAppManifest?, completion: @escaping ((Result<Bool, MASDKError>) -> Void))
}

public extension MiniAppViewable {
    func load(fromCache: Bool = false, completion: @escaping ((Result<Bool, MASDKError>) -> Void)) {
        load(fromCache: fromCache, completion: completion)
    }

    @discardableResult
    func loadAsync(fromCache: Bool = false) async throws -> MiniAppView.MiniAppLoadStatus {
        try await loadAsync(fromCache: fromCache)
    }

    func loadFromBundle(miniAppManifest: MiniAppManifest? = nil, completion: @escaping ((Result<Bool, MASDKError>) -> Void)) {
        loadFromBundle(miniAppManifest: miniAppManifest, completion: completion)
    }
}
