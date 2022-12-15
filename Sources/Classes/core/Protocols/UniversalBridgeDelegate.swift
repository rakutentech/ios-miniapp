import Foundation

/**
 Public Protocol that will be used by the Mini App to communicate
 with the Native implementation for sending string data through interface 1 mechanism
 */
public protocol UniversalBridgeDelegate: AnyObject {
    /// Interface that is used to send the string content from the Mini app. This must be implemented in the host app to receive the message from MiniApp.
    func sendJsonToHostApp(info: String, completionHandler: @escaping (Result<MASDKProtocolResponse, UniversalBridgeError>) -> Void)
}
