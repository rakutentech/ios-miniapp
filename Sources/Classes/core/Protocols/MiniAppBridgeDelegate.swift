import Foundation

/**
 Public Protocol that will be used by the Mini App to communicate
 with the Native implementation for sending string data through interface 1 mechanism
 */
public protocol MiniAppBridgeDelegate: AnyObject {
    /// Interface that is used to send the string content from the Mini app
    func sendJsonToHostApp(info: MiniAppBridgeContent, completionHandler: @escaping (Result<MASDKProtocolResponse, Error>) -> Void)
}
