import Foundation

/**
 Public Protocol that will be used by the Mini App to communicate
 with the Native implementation for Purchase related flow
*/
public protocol MiniAppPurchaseDelegate: AnyObject {
    /// Interface used to purchase a product using Id
    func purchaseProduct(withId: String,
                         completionHandler: @escaping (Result<MAProductResponse, MAProductResponseError>) -> Void)
}
