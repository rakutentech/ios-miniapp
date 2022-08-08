import Foundation
import UIKit

public protocol MiniAppViewable: UIView {

    /// Loads the MiniApp (getInfo, download etc) and initialized the webview.
    /// After load is complete it will display the loaded MiniApp or an error.
    ///
    /// - Parameters:
    ///     -   completion: Completes with an optional MiniAppWebView that will be added onto the View or throws an MASDKError
    func load(fromCache: Bool, completion: @escaping ((Result<Bool, MASDKError>) -> Void))

    /// Loads the MiniApp async (getInfo, download etc) and initialized the webview
    /// After load is complete it will display the loaded MiniApp or an error.
    ///
    func load(fromCache: Bool) async throws -> AsyncThrowingStream<Void, Error>

    /// Alert Info when closing the MiniApp
    ///
    var alertInfo: CloseAlertInfo? { get }
}

public extension MiniAppViewable {
    func load(fromCache: Bool = false, completion: @escaping ((Result<Bool, MASDKError>) -> Void)) {
        load(fromCache: fromCache, completion: completion)
    }
    func load(fromCache: Bool = false) async throws -> AsyncThrowingStream<Void, Error> {
        try await load(fromCache: fromCache)
    }
}
