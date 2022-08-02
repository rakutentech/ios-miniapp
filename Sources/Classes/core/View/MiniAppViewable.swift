import Foundation
import UIKit

public protocol MiniAppViewable: UIView {

    /// Loads the MiniApp (getInfo, download etc) and initialized the webview.
    /// After load is complete it will display the loaded MiniApp or an error.
    ///
    /// - Parameters:
    ///     -   completion: Completes with an optional MiniAppWebView that will be added onto the View or throws an MASDKError
    func load(completion: @escaping ((Result<Bool, MASDKError>) -> Void))

    /// Loads the MiniApp async (getInfo, download etc) and initialized the webview
    /// After load is complete it will display the loaded MiniApp or an error.
    ///
    func load() async throws -> AsyncThrowingStream<Void, Error>

}
