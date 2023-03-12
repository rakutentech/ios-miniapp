import UIKit

/**
 Public Protocol that will be used by any hosting application
 to communicate with the Mini App display module
 */

public protocol MiniAppDisplayDelegate: AnyObject {

    /// Get the view of the Mini app
    func getMiniAppView() -> UIView

    /// Interface  that will be used by the Host app to send Json
    func sendJsonToMiniApp(string jsonString: String)

}
