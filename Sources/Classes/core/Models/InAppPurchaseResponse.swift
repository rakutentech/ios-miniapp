import Foundation
import StoreKit

public enum MAProductResponseError: String, Codable, MiniAppErrorProtocol {

    case productNotFound
    case failedToConformToProtocol

    var name: String {
        return self.rawValue
    }

    public var description: String {
        switch self {
        case .productNotFound:
        return "Host app Error"
        case .failedToConformToProtocol:
        return "Host app failed to implement required interface"
        }
    }
}

public enum MAProductResponseStatus: String, Codable {
    case purchased = "PURCHASED"
    case failed = "FAILED"
    case restored = "RESTORED"
}

public struct MAProductResponse: Codable {
    let status: MAProductResponseStatus
    let product: PurchasedProduct

    public init(status: MAProductResponseStatus, product: PurchasedProduct) {
        self.status = status
        self.product = product
    }
}

public struct PurchasedProduct: Codable {
    let product: ProductInfo
    let transactionId: String
    let transactionDate: String

    public init(product: ProductInfo, transactionId: String, transactionDate: String) {
        self.product = product
        self.transactionId = transactionId
        self.transactionDate = transactionDate
    }
}

public struct ProductInfo: Codable {
    let title: String
    let description: String
    let id: String
    let price: ProductPrice

    public init(title: String, description: String, id: String, price: ProductPrice) {
        self.title = title
        self.description = description
        self.id = id
        self.price = price
    }
}

public struct ProductPrice: Codable {
    let currencyCode: String
    let price: String

    public init(currencyCode: String, price: String) {
        self.currencyCode = currencyCode
        self.price = price
    }
}
