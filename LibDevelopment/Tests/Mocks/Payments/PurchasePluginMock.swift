//
//  PurchasePluginMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 04.05.2022.
//

import Foundation
import PaltaLibPayments

final class PurchasePluginMock: PurchasePlugin {
    var delegate: PurchasePluginDelegate?
    
    var logInUserId: UserId?
    var logInCompletion: ((Result<(), Error>) -> Void)?
    var logOutCalled = false
    var getProductsIndentifiers: [String]?
    var getPaidFeaturesCompletion: ((Result<PaidFeatures, Error>) -> Void)?
    var getProductsCompletion: ((Result<Set<Product>, Error>) -> Void)?
    var getPromotionalOfferCompletion: ((PurchasePluginResult<PromoOffer, Error>) -> Void)?
    var purchaseCompletion: ((PurchasePluginResult<SuccessfulPurchase, Error>) -> Void)?
    var restorePurchasesCompletion: ((Result<PaidFeatures, Error>) -> Void)?
    var appsflyerID: String?
    var attributes: [String : String]?
    var collectDeviceIdentifiersCalled = false
    var codeRedemptionCalled = false
    var codeRedemptionResult: PurchasePluginResult<(), Error>?

    func logIn(appUserId: UserId, completion: @escaping (Result<(), Error>) -> Void) {
        logInUserId = appUserId
        logInCompletion = completion
    }

    func logOut() {
        logOutCalled = true
    }
    
    func getPaidFeatures(_ completion: @escaping (Result<PaidFeatures, Error>) -> Void) {
        getPaidFeaturesCompletion = completion
    }
    
    
    func getShowcaseProducts(_ completion: @escaping (Result<[Product], Error>) -> Void) {
    }
    
    func getProducts(with productIdentifiers: [String], _ completion: @escaping (Result<Set<Product>, Error>) -> Void) {
        getProductsCompletion = completion
        getProductsIndentifiers = productIdentifiers
    }
    
    func getPromotionalOffer(for productDiscount: ProductDiscount, product: Product, _ completion: @escaping (PurchasePluginResult<PromoOffer, Error>) -> Void) {
        getPromotionalOfferCompletion = completion
    }
    
    func purchase(_ product: Product, with promoOffer: PromoOffer?, _ completion: @escaping (PurchasePluginResult<SuccessfulPurchase, Error>) -> Void) {
        purchaseCompletion = completion
    }
    
    func restorePurchases(completion: @escaping (Result<PaidFeatures, Error>) -> Void) {
        restorePurchasesCompletion = completion
    }
    
    func setAppsflyerID(_ appsflyerID: String?) {
        self.appsflyerID = appsflyerID
    }
    
    func setAppsflyerAttributes(_ attributes: [String : String]) {
        self.attributes = attributes
    }
    
    func collectDeviceIdentifiers() {
        collectDeviceIdentifiersCalled = true
    }
    
    func presentCodeRedemptionUI() -> PurchasePluginResult<(), Error> {
        codeRedemptionCalled = true
        return codeRedemptionResult ?? .notSupported
    }
}

extension PurchasePluginMock: Equatable {
    static func ==(lhs: PurchasePluginMock, rhs: PurchasePluginMock) -> Bool {
        lhs === rhs
    }
}
