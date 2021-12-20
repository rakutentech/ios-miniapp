/**
 Public Protocol that will be used by the Mini App to communicate
 with the Native implementation for content sharing mechanism
 */
public protocol MiniAppShareContentDelegate: AnyObject {
    /// Interface that is used to share the content from the Mini app
    func shareContent(info: MiniAppShareContent, completionHandler: @escaping (Result<MASDKProtocolResponse, Error>) -> Void)
}

public extension MiniAppShareContentDelegate {
    func shareContent(info: MiniAppShareContent, completionHandler: @escaping (Result<MASDKProtocolResponse, Error>) -> Void) {
        let activityController = UIActivityViewController(activityItems: [info.messageContent], applicationActivities: nil)
        activityController.completionWithItemsHandler = { (_, _, _, error: Error?) in
            if let err = error {
                completionHandler(.failure(err))
            } else {
                completionHandler(.success(.success))
            }
        }
        UIViewController.topViewController()?.present(activityController,
            animated: true,
            completion: nil)
    }
}
