/**
 Public Protocol that will be used by any hosting application
 to communicate with the Mini App display module
 */

public typealias MiniAppDisplayProtocol = MiniAppDisplayDelegate

public protocol MiniAppDisplayDelegate: class {

    /// Get the view of the Mini app
    func getMiniAppView() -> UIView

}
