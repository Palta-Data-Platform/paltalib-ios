//
//  PBPurchasePlugin.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 04.05.2022.
//

import Foundation
import StoreKit

public final class PBPurchasePlugin: PurchasePlugin {
    public var delegate: PurchasePluginDelegate?
    
    var userId: UserId?

    private let assembly: PaymentsAssembly

    init(assembly: PaymentsAssembly) {
        self.assembly = assembly
    }
    
    public func logIn(appUserId: UserId, completion: @escaping (Result<(), Error>) -> Void) {
        userId = appUserId
        completion(.success(()))
    }
    
    public func logOut() {
        userId = nil
    }
    
    public func getPaidFeatures(_ completion: @escaping (Result<PaidFeatures, Error>) -> Void) {
        guard let userId = userId else {
            completion(.failure(PaymentsError.noUserId))
            return
        }

        assembly.paidFeaturesService.getPaidFeatures(for: userId) {
            completion($0.mapError { $0 as Error })
        }
    }
    
    public func getProducts(
        with productIdentifiers: [String],
        _ completion: @escaping (Result<Set<Product>, Error>) -> Void
    ) {
        completion(.success([]))
    }
    
    public func getShowcaseProducts(_ completion: @escaping (Result<[Product], Error>) -> Void) {
        guard let userId = userId else {
            completion(.failure(PaymentsError.noUserId))
            return
        }

        assembly.makeShowcaseFlow(userId: userId).start { result in
            completion(result.mapError { $0 as Error })
        }
    }
    
    public func getPromotionalOffer(
        for productDiscount: ProductDiscount,
        product: Product,
        _ completion: @escaping (PurchasePluginResult<PromoOffer, Error>) -> Void
    ) {
        completion(.notSupported)
    }
    
    public func purchase(
        _ product: Product,
        with promoOffer: PromoOffer?,
        _ completion: @escaping (PurchasePluginResult<SuccessfulPurchase, Error>) -> Void
    ) {
        guard let product = product.originalEntity as? ShowcaseProduct else {
            completion(.notSupported)
            return
        }
        
        guard let userId = userId else {
            completion(.failure(PaymentsError.noUserId))
            return
        }

        assembly.makeCheckoutFlow(userId: userId, product: product).start { result in
            switch result {
            case .success(let features):
                completion(.success(.init(transaction: .inApp, paidFeatures: features)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func purchase2(_ product: Product, stages: @escaping (String) -> Void, _ completion: @escaping (PurchasePluginResult<SuccessfulPurchase, Error>) -> Void) {
        guard let product = product.originalEntity as? ShowcaseProduct else {
            completion(.notSupported)
            return
        }
        
        guard let userId = userId else {
            completion(.failure(PaymentsError.noUserId))
            return
        }
        
        assembly.makeCheckoutFlow(userId: userId, product: product, logging: stages).start { result in
            switch result {
            case .success(let features):
                completion(.success(.init(transaction: .inApp, paidFeatures: features)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func restorePurchases(completion: @escaping (Result<PaidFeatures, Error>) -> Void) {
        getPaidFeatures(completion)
    }
    
    public func presentCodeRedemptionUI() -> PurchasePluginResult<(), Error> {
        return .notSupported
    }
    
    public func setAppsflyerID(_ appsflyerID: String?) {
    }
    
    public func setAppsflyerAttributes(_ attributes: [String : String]) {
    }
    
    public func collectDeviceIdentifiers() {
    }
}

public extension PBPurchasePlugin {
    convenience init(apiKey: String, environment: Environment) {
        self.init(assembly: RealPaymentsAssembly(apiKey: apiKey, environment: environment))
    }
}
