import MiniApp
import UIKit

extension ViewController: MiniAppPurchaseDelegate {
    func purchaseProduct(withId: String, completionHandler: @escaping (Result<MAProductResponse, MAProductResponseError>) -> Void) {
        miniAppIAPModule?.initiateProductPayment(productId: withId, completionHandler: completionHandler)
    }
}
