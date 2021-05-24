import Foundation
import UIKit

public struct MiniAppUIParams {

    var title: String
    var miniAppId: String
    var config: MiniAppSdkConfig?
    var messageInterface: MiniAppMessageDelegate
    var navigationInterface: MiniAppNavigationDelegate?
    var queryParams: String?

    public init(
        title: String = "",
        miniAppId: String,
        config: MiniAppSdkConfig? = nil,
        messageInterface: MiniAppMessageDelegate,
        navigationInterface: MiniAppNavigationDelegate? = nil,
        queryParams: String? = nil
    ) {
        self.title = title
        self.miniAppId = miniAppId
        self.config = config
        self.messageInterface = messageInterface
        self.queryParams = queryParams
    }
}

/// Mini App UI Public API methods
public class MiniAppUI {

    private static let sharedInstance = MiniAppUI()
    private let realMiniAppUI = RealMiniAppUI()

    public class func shared() -> MiniAppUI {
        return sharedInstance
    }

    /// Instance of MiniAppViewController
    ///
    /// - Parameters:
    ///     -   params: MiniAppUIParams used for creating the MiniApp View
    public func create(params: MiniAppUIParams) -> MiniAppViewController {
        realMiniAppUI.create(params: params)
    }

    /// Launch a preconfigured NavigationController with an embedded MiniAppViewController
    ///
    /// - Parameters:
    ///     -   base: Base ViewController which is used for presenting the MiniApp (Fullscreen)
    ///     -   params: MiniAppUIParams used for creating the MiniApp View
    ///     -   delegate: MiniAppUIDelegate containing actions triggered by MiniAppViewController
    public func launch(base: UIViewController, params: MiniAppUIParams, delegate: MiniAppUIDelegate) {
        realMiniAppUI.launch(base: base, params: params, delegate: delegate)
    }

}

internal class RealMiniAppUI {

    func create(params: MiniAppUIParams) -> MiniAppViewController {
        let miniAppVC = MiniAppViewController(
            title: params.title,
            appId: params.miniAppId,
            config: params.config,
            messageDelegate: params.messageInterface,
            navDelegate: params.navigationInterface,
            queryParams: params.queryParams
        )
        return miniAppVC
    }

    func launch(base: UIViewController, params: MiniAppUIParams, delegate: MiniAppUIDelegate) {
        let miniAppVC = create(params: params)
        miniAppVC.delegate = delegate
        let nvc = UINavigationController(rootViewController: miniAppVC)
        nvc.modalPresentationStyle = .fullScreen
        base.present(nvc, animated: true, completion: nil)
    }

}
