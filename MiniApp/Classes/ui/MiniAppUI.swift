import Foundation
import UIKit

public struct MiniAppUIParams {
    var title: String
    var miniAppId: String
    var config: MiniAppSdkConfig?
    var messageInterface: MiniAppMessageDelegate
    var queryParams: String?

    public init(title: String = "", miniAppId: String, config: MiniAppSdkConfig? = nil, messageInterface: MiniAppMessageDelegate, queryParams: String? = nil) {
        self.title = title
        self.miniAppId = miniAppId
        self.config = config
        self.messageInterface = messageInterface
        self.queryParams = queryParams
    }
}

public class MiniAppUI {

    private static let sharedInstance = MiniAppUI()
    private let realMiniAppUI = RealMiniAppUI()

    public class func shared() -> MiniAppUI {
        return sharedInstance
    }

    public func create(params: MiniAppUIParams) -> MiniAppViewController {
        realMiniAppUI.create(params: params)
    }

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
            navDelegate: nil,
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

class TestMiniAppVC : MiniAppViewController {
    
    override func closePressed() {
        print("close pressu")
    }
    
}
