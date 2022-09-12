import Foundation
import UIKit
import MiniApp

class MiniAppViewNavigationDelegator: MiniAppNavigationDelegate {
    
    var onShouldOpenUrl: ((URL, MiniAppNavigationResponseHandler?, MiniAppNavigationResponseHandler?) -> Void)?
    //var externalLinkResponseHandler: MiniAppNavigationResponseHandler?
    //var onCloseHandler: MiniAppNavigationResponseHandler?
    
    func miniAppNavigation(shouldOpen url: URL, with responseHandler: @escaping MiniAppNavigationResponseHandler, onClose closeHandler: MiniAppNavigationResponseHandler?) {
        //onShouldOpenUrl?(url, responseHandler, closeHandler)
        if url.absoluteString.starts(with: "data:") {
            navigateForBase64(url: url)
        } else {
            guard !isDeepLinkURL(url: url) else {
                return
            }
            MiniAppExternalWebViewController.presentModally(
                url: url,
                externalLinkResponseHandler: responseHandler,
                onCloseHandler: closeHandler
            )
        }
    }

    func navigateForBase64(url: URL) {
        let topViewController = UIApplication.shared.keyWindow?.topController()
        // currently js sdk is passing no base64 data type
        let base64String = url.absoluteString.components(separatedBy: ",").last ?? ""
        guard let base64Data = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) else { return }
        var activityItem: Any?
        if let image = UIImage(data: base64Data) {
            activityItem = image
        } else {
            activityItem = base64Data
        }
        guard let wrappedActivityItem = activityItem else { return }
        let activityViewController = MiniAppActivityController(activityItems: [wrappedActivityItem], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { (_, completed, _, _) in
            guard completed else { return }
            let controller = UIAlertController(title: "Nice", message: "Successfully shared!", preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            topViewController?.present(controller, animated: true, completion: nil)
        }
        topViewController?.present(activityViewController, animated: true)
    }

    func isDeepLinkURL(url: URL) -> Bool {
        if getDeepLinksList().contains(where: url.absoluteString.hasPrefix) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return true
        }
        return false
    }
}
