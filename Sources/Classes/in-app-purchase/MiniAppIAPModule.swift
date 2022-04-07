import Foundation
import StoreKit

public class MiniAppIAPModule: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {

    public typealias ProductResponseCompletionHandler = ((Result<MAProductResponse, MAProductResponseError>)) -> Void
    var productResponseHandlerObj: ProductResponseCompletionHandler?
    var paymentProductObj: SKProduct?
    private var models = [SKProduct]()
    var productId: String = ""

    public func initiateProductPayment(productId: String, completionHandler: @escaping ProductResponseCompletionHandler) {
        self.productResponseHandlerObj = completionHandler
        self.productId = productId
        let productRequest = SKProductsRequest(productIdentifiers: Set([self.productId]))
        productRequest.delegate = self
        productRequest.start()
    }

    func displayPaymentScreen(product: SKProduct) {
        SKPaymentQueue.default().add(self)
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
        paymentProductObj = product
    }

    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.models = response.products
            if response.products.count == 0 {
                self.productResponseHandlerObj?(.failure(.productNotFound))
            } else {
                self.displayPaymentScreen(product: response.products[0])
            }
        }
    }

    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach({
            switch $0.transactionState {
            case .purchasing, .deferred, .restored:
                break
            case .purchased:
                SKPaymentQueue.default().finishTransaction($0)
                sendTranactionDetails(transaction: $0, status: .purchased)
            case .failed:
                SKPaymentQueue.default().finishTransaction($0)
                sendTranactionDetails(transaction: $0, status: .failed)
            @unknown default:
                print("Default", $0.payment.productIdentifier)
            }
        })
    }

    func sendTranactionDetails(transaction: SKPaymentTransaction, status: MAProductResponseStatus) {
        let productPrice = ProductPrice(currencyCode: paymentProductObj?.priceLocale.currencyCode ?? "UNKNOWN", price: paymentProductObj?.price.stringValue ?? "UNKNOWN")
        let productInfo = ProductInfo(title: paymentProductObj?.localizedTitle ?? "",
                                      description: paymentProductObj?.localizedDescription ?? "",
                                      id: paymentProductObj?.productIdentifier ?? "",
                                      price: productPrice)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        guard let transactionDate = transaction.transactionDate, let transactionId = transaction.transactionIdentifier else {
            productResponseHandlerObj?(.success(MAProductResponse(status: status,
                                                                  product: PurchasedProduct(product: productInfo,
                                                                                            transactionId: "UNKNOWN",
                                                                                            transactionDate: "UNKNOWN"))))
            return
        }
        productResponseHandlerObj?(.success(MAProductResponse(status: status,
                                                              product: PurchasedProduct(product: productInfo,
                                                                                        transactionId: transactionId,
                                                                                        transactionDate: dateFormatter.string(from: transactionDate)))))
    }

}
