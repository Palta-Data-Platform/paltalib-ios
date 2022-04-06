import Foundation
import StoreKit
import Purchases
import PaltaLibAttribution
import PaltaLibCore

public final class PaltaPurchases {
    public static let instance: PaltaPurchases = {
        guard isConfigured else {
            fatalError("SDK must be configured before accessing instance")
        }

        #warning("TODO: PaltaPurchases should not depend on PaltaAppsflyerAdapter, there should be a way to install components separatly")
        return PaltaPurchases(purchases: Purchases.shared,
                              appsflyerAdapter: PaltaAppsflyerAdapter.sharedInstance,
                              httpClient: HTTPClient.defaultWebSubscriptionClient)
    }()

    private let purchases: Purchases
    private let appsflyerAdapter: PaltaAppsflyerAdapter
    let httpClient: HTTPClient
    private let statusListener = PurchaserInfoListener()
    private static var isConfigured = false
    private (set) static var webSubscriptionID: String?

    private init(purchases: Purchases,
                 appsflyerAdapter: PaltaAppsflyerAdapter,
                 httpClient: HTTPClient) {
        self.purchases = purchases
        self.appsflyerAdapter = appsflyerAdapter
        self.httpClient = httpClient

        purchases.delegate = statusListener
        purchases.setAppsflyerID(appsflyerAdapter.appsflyerUID)
    }

    public static func configureWith(revenueCatApiKey: String,
                                     userID: String?,
                                     revenueCatDebugLogsEnabled: Bool,
                                     webSubscriptionID: String?) {
        configure(using: .init(revenueCatApiKey: revenueCatApiKey,
                               revenueCatUserID: userID,
                               revenueCatDebugLogsEnabled: revenueCatDebugLogsEnabled,
                               webSubscriptionID: webSubscriptionID))
    }

    static func configure(using configuration: Configuration) {
        defer {
            isConfigured = true
        }
        Purchases.logLevel = configuration.revenueCatDebugLogsEnabled ? .debug : .warn
        Purchases.configure(withAPIKey: configuration.revenueCatApiKey,
                            appUserID: configuration.revenueCatUserID)
        self.webSubscriptionID = configuration.webSubscriptionID
    }

    public func purchaseProduct(_ product: SKProduct,
                                completion: @escaping PurchaseCompletedBlock) {
        purchases.purchaseProduct(product) { transaction, info, error, isCancelled in
            if isCancelled {
                completion(.userCancelled)
                return
            } else if let error = error {
                completion(.error(error: error))
                return
            } else if let info = info {
                let purchaserInfo = PurchaserInfoRCAdapter(info: info)
                completion(.success(trancaction: transaction, info: purchaserInfo))
                return
            } else {
                completion(.error(error: PurchasesError.unknown))
            }
        }
    }

    @available(iOS 12.2, *)
    public func purchaseProduct(_ product: SKProduct,
                                withDiscount discount: SKPaymentDiscount,
                                completion: @escaping PurchaseCompletedBlock) {
        purchases.purchaseProduct(product, discount: discount) { transaction, info, error, isCancelled in
            if isCancelled {
                completion(.userCancelled)
                return
            } else if let error = error {
                completion(.error(error: error))
                return
            } else if let info = info {
                let purchaserInfo = PurchaserInfoRCAdapter(info: info)
                completion(.success(trancaction: transaction, info: purchaserInfo))
                return
            } else {
                completion(.error(error: PurchasesError.unknown))
            }
        }
    }

    public func restore(completion: @escaping (Result<PurchaserInfo, Error>) -> Void) {
        purchases.restoreTransactions { info, error in
            if let error = error {
                completion(.failure(error))
                return
            } else if let info = info {
                let purchaserInfo = PurchaserInfoRCAdapter(info: info)
                completion(.success(purchaserInfo))
                return
            } else {
                completion(.failure(PurchasesError.unknown))
            }
        }
    }

    public func configure(userID: String, completion: @escaping (Result<PurchaserInfo, Error>) -> Void) {
        purchases.logIn(userID) { info, created, error in
            if let error = error {
                completion(.failure(error))
            } else if let info = info {
                let purchaserInfo = PurchaserInfoRCAdapter(info: info)
                completion(.success(purchaserInfo))
                return
            } else {
                completion(.failure(PurchasesError.unknown))
            }
        }
    }

    public func fetchProducts(byProductIDs productIDs: [String],
                              completion: @escaping (Result<[SKProduct], Error>) -> Void) {
        purchases.products(productIDs) { products in
            let fetchedProductIDs = products.map { $0.productIdentifier }

            guard Set(productIDs).isSubset(of: Set(fetchedProductIDs)) else {
                // RevenueCat doesn't provide interface for SKProductsRequest failures handling
                // in the case of error it just returns an empty or incomplete products array
                // it may happen due to bad network conditions
                completion(.failure(PurchasesError.productsFetchError))
                return
            }

            completion(.success(products))
        }
    }

    public func fetchProducts(forOfferingName name: String? = nil,
                              completion: @escaping (Result<[String: SKProduct], Error>) -> Void) {
        purchases.offerings { offerings, error in
            if let error = error {
                completion(.failure(error))
            } else if let offerings = offerings {
                if let name = name {
                    guard let offering = offerings[name] else {
                        completion(.failure(PurchasesError.invalidOffering))
                        return
                    }

                    completion(.success(offering.productsByPackageID))
                } else if let offering = offerings.current {
                    completion(.success(offering.productsByPackageID))
                } else {
                    completion(.failure(PurchasesError.noCurrentOffering))
                }
            } else {
                completion(.failure(PurchasesError.unknown))
            }
        }
    }

    public func fetchPurchaserInfo(_ completion: @escaping (Result<PurchaserInfo, Error>) -> Void) {
        purchases.purchaserInfo { info, error in
            if let error = error {
                completion(.failure(error))
                return
            } else if let info = info {
                let purchaserInfo = PurchaserInfoRCAdapter(info: info)
                completion(.success(purchaserInfo))
                return
            } else {
                completion(.failure(PurchasesError.unknown))
            }
        }
    }

    @available(iOS 12.2, *)
    public func fetchPayment(for discount: SKProductDiscount,
                             product: SKProduct,
                             completion: @escaping (Result<SKPaymentDiscount, Error>) -> Void) {

        purchases.paymentDiscount(for: discount, product: product) { paymentDiscount, error in
            if let error = error {
                completion(.failure(error))
            } else if let paymentDiscount = paymentDiscount {
                completion(.success(paymentDiscount))
            } else {
                completion(.failure(PurchasesError.unknown))
            }
        }
    }

    public func invalidatePurchaserInfoCache() {
        purchases.invalidatePurchaserInfoCache()
    }
}

extension PaltaPurchases {
    public enum PurchaseResults {
        case userCancelled
        case error(error: Error)
        case success(trancaction: SKPaymentTransaction?, info: PurchaserInfo)
    }

    public typealias PurchaseCompletedBlock = (PurchaseResults) -> Void
    public typealias DefferedPurchaseBlock = (@escaping PurchaseCompletedBlock) -> Void
}

extension PaltaPurchases {
    public func subscribeOnPurchaserInfoUpdated(_ onUpdated: @escaping (PurchaserInfo) -> Void) -> AnyObject {
        return statusListener.subscribeOnPurchaserInfoUpdated { info in
            onUpdated(PurchaserInfoRCAdapter(info: info))
        }
    }

    public func subscribeOnPromoProductPurchase(_ onUpdated: @escaping (SKProduct, @escaping DefferedPurchaseBlock) -> Void) -> AnyObject {
        return statusListener.subscribeOnPromoProductPurchase { product, deferredPurchaseBlock in
            let deferredBlock: DefferedPurchaseBlock = { purchaseCompletedBlock in
                deferredPurchaseBlock { (transaction, purchaserInfo, error, userCancelled) in
                    if userCancelled {
                        purchaseCompletedBlock(.userCancelled)
                        return
                    } else if let error = error {
                        purchaseCompletedBlock(.error(error: error))
                        return
                    } else if let info = purchaserInfo {
                        let purchaserInfo = PurchaserInfoRCAdapter(info: info)
                        purchaseCompletedBlock(.success(trancaction: transaction, info: purchaserInfo))
                        return
                    } else {
                        purchaseCompletedBlock(.error(error: PurchasesError.unknown))
                    }
                }
            }
            onUpdated(product, deferredBlock)
        }
    }
}

extension PaltaPurchases {
    var revenueCatID: String {
        return purchases.appUserID
    }
}

private extension HTTPClient {
    static var defaultWebSubscriptionClient: HTTPClient {
        return HTTPClient()
    }
}
