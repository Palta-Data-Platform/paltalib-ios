//
//  PaltaPurchasesProtocol.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 11/07/2022.
//

import Foundation

public protocol PaltaPurchasesProtocol: AnyObject {
    var userId: UserId? { get }
    
    var delegate: PaltaPurchasesDelegate? { get set }

    func setup(with plugins: [PurchasePlugin])
    
    func logIn(appUserId: UserId, completion: @escaping (Result<(), Error>) -> Void)
    
    func logOut()
    
    func getPaidFeatures(_ completion: @escaping (Result<PaidFeatures, Error>) -> Void)
    
    func getProducts(
        with productIdentifiers: [String],
        completion: @escaping (Result<Set<Product>, Error>) -> Void
    )
    
    @available(iOS 12.2, *)
    func getPromotionalOffer(
        for productDiscount: ProductDiscount,
        product: Product,
        _ completion: @escaping (Result<PromoOffer, Error>) -> Void
    )
    
    func purchase(
        _ product: Product,
        with promoOffer: PromoOffer?,
        _ completion: @escaping (Result<SuccessfulPurchase, Error>) -> Void
    )
    
    func restorePurchases(completion: @escaping (Result<PaidFeatures, Error>) -> Void)
    
    @available(iOS 14.0, *)
    func presentCodeRedemptionUI()
    
    func setAppsflyerID(_ appsflyerID: String?)
    
    func setAppsflyerAttributes(_ attributes: [String: String])
    
    func collectDeviceIdentifiers()
}
