import Foundation
import RSignatureVerifier

public struct MiniAppSignatureParams {

}

/// Mini App Signature Public API methods
public extension MiniApp {
    public class func verifySignature(signature: String, data: Data, handler: @escaping (Bool) -> Void) {
        RSignatureVerifier(baseURL: URL(string: "https://endpoint.url")!,
                           subscriptionKey: "endpoint-subscription-key")
        .verify(signature: signature, keyId: "", data: data, resultHandler: handler)
    }
}

internal class RealMiniAppSignature {

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
