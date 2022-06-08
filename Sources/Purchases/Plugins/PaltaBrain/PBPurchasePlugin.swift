//
//  PBPurchasePlugin.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 04.05.2022.
//

import Foundation

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
        _ completion: @escaping (PurchasePluginResult<[Product], Error>) -> Void
    ) {
        completion(.notSupported)
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
        completion(.notSupported)
    }
    
    public func restorePurchases() {
    }
    
    public func setAppsflyerID(_ appsflyerID: String?) {
    }
    
    public func setAppsflyerAttributes(_ attributes: [String : String]) {
    }
    
    public func collectDeviceIdentifiers() {
    }
}

public extension PBPurchasePlugin {
    convenience init(apiKey: String) {
        self.init(assembly: RealPaymentsAssembly(apiKey: apiKey))
    }
}
