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
    
    var logInUserId: String?
    var logOutCalled = false
    var getPaidServicesCompletion: ((Result<PaidServices, Error>) -> Void)?
    var getProductsCompletion: ((PurchasePluginResult<[Product], Error>) -> Void)?
    var getPromotionalOfferCompletion: ((PurchasePluginResult<PromoOffer, Error>) -> Void)?
    var purchaseCompletion: ((PurchasePluginResult<SuccessfulPurchase, Error>) -> Void)?
    var restorePurchasesCalled = false
    var appsflyerID: String?
    var attributes: [String : String]?
    var collectDeviceIdentifiersCalled = false

    func logIn(appUserId: String) {
        logInUserId = appUserId
    }

    func logOut() {
        logOutCalled = true
    }
    
    func getPaidServices(_ completion: @escaping (Result<PaidServices, Error>) -> Void) {
        getPaidServicesCompletion = completion
    }
    
    func getProducts(with productIdentifiers: [String], _ completion: @escaping (PurchasePluginResult<[Product], Error>) -> Void) {
        getProductsCompletion = completion
    }
    
    func getPromotionalOffer(for productDiscount: ProductDiscount, product: Product, _ completion: @escaping (PurchasePluginResult<PromoOffer, Error>) -> Void) {
        getPromotionalOfferCompletion = completion
    }
    
    func purchase(_ product: Product, with promoOffer: PromoOffer?, _ completion: @escaping (PurchasePluginResult<SuccessfulPurchase, Error>) -> Void) {
        purchaseCompletion = completion
    }
    
    func restorePurchases() {
        restorePurchasesCalled = true
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
}

extension PurchasePluginMock: Equatable {
    static func ==(lhs: PurchasePluginMock, rhs: PurchasePluginMock) -> Bool {
        lhs === rhs
    }
}
