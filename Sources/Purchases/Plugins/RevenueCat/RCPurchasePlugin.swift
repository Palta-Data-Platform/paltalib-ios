//
//  RCPurchasePlugin.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 04.05.2022.
//

import Foundation
import RevenueCat

public final class RCPurchasePlugin: NSObject, PurchasePlugin {
    public var delegate: PurchasePluginDelegate?

    private lazy var purchases = Purchases.shared
    
    public init(apiKey: String) {
        Purchases.configure(withAPIKey: apiKey)
    }

    public func logIn(appUserId: UserId) {
        purchases.logIn(appUserId.stringValue, completion: { _, _, _ in })
    }

    public func logOut() {
        purchases.logOut(completion: nil)
    }
    
    public func getPaidServices(_ completion: @escaping (Result<PaidServices, Error>) -> Void) {
        purchases.getCustomerInfo { customerInfo, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(customerInfo?.paidServices ?? PaidServices()))
            }
        }
    }
    
    public func getProducts(
        with productIdentifiers: [String],
        _ completion: @escaping (PurchasePluginResult<[Product], Error>) -> Void
    ) {
        purchases.getProducts(productIdentifiers) { products in
            completion(.success(products.map(RCProduct.init)))
        }
    }
    
    @available(iOS 12.2, *)
    public func getPromotionalOffer(
        for productDiscount: ProductDiscount,
        product: Product,
        _ completion: @escaping (PurchasePluginResult<PromoOffer, Error>) -> Void
    ) {
        guard
            let productDiscount = productDiscount as? StoreProductDiscount,
            let product = product.storeProduct
        else {
            completion(.notSupported)
            return
        }
        
        purchases.getPromotionalOffer(forProductDiscount: productDiscount, product: product) { offer, error in
            if let offer = offer {
                completion(.success(offer))
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
    
    public func purchase(
        _ product: Product,
        with promoOffer: PromoOffer?,
        _ completion: @escaping (PurchasePluginResult<SuccessfulPurchase, Error>) -> Void
    ) {
        guard let product = product.storeProduct else {
            completion(.notSupported)
            return
        }
        
        if let promoOffer = promoOffer as? PromotionalOffer {
            if #available(iOS 12.2, *) {
                purchases.purchase(
                    product: product,
                    promotionalOffer: promoOffer,
                    completion: makeRCCompletionBlock(from: completion)
                )
            } else {
                completion(.notSupported)
            }
        } else if promoOffer == nil {
            purchases.purchase(
                product: product,
                completion: makeRCCompletionBlock(from: completion)
            )
        } else {
            completion(.notSupported)
        }
    }
    
    public func restorePurchases() {
        purchases.restorePurchases()
    }
    
    public func setAppsflyerID(_ appsflyerID: String?) {
        purchases.setAppsflyerID(appsflyerID)
    }
    
    public func setAppsflyerAttributes(_ attributes: [String: String]) {
        purchases.setAttributes(attributes)
    }
    
    public func collectDeviceIdentifiers() {
        purchases.collectDeviceIdentifiers()
    }
    
    private func makeRCCompletionBlock(
        from pluginCompletion: @escaping (PurchasePluginResult<SuccessfulPurchase, Error>) -> Void
    ) -> (StoreTransaction?, CustomerInfo?, Error?, Bool) -> Void {
        { _, customerInfo, error, _ in
            if let error = error {
                pluginCompletion(.failure(error))
            } else {
                pluginCompletion(
                    .success(
                        SuccessfulPurchase(
                            transaction: .inApp,
                            paidServices: PaidServices()
                        )
                    )
                )
            }
        }
    }
}

extension RCPurchasePlugin: PurchasesDelegate {
    public func purchases(
        _ purchases: Purchases,
        readyForPromotedProduct product: StoreProduct,
        purchase startPurchase: @escaping StartPurchaseBlock
    ) {
        delegate?.purchasePlugin(
            self,
            shouldPurchase: RCProduct(product: product)
        ) { [weak self] completion in
            guard let self = self else { return }
            
            startPurchase(self.makeRCCompletionBlock(from: completion))
        }
    }
}
