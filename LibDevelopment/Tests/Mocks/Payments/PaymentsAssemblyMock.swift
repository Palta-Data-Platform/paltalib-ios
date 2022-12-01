//
//  PaymentsAssemblyMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 27/05/2022.
//

import Foundation
@testable import PaltaLibPayments

final class PaymentsAssemblyMock: PaymentsAssembly {
    var showcaseUserId: UserId?
    
    var checkoutUserId: UserId?
    var checkoutProduct: ShowcaseProduct?

    let paidFeaturesMock = PaidFeaturesServiceMock()
    let showcaseFlowMock = ShowcaseFlowMock()
    let checkoutFlowMock = CheckoutFlowMock()
    
    var paidFeaturesService: PaidFeaturesService {
        paidFeaturesMock
    }
    
    func makeShowcaseFlow(userId: UserId) -> ShowcaseFlow {
        showcaseUserId = userId
        return showcaseFlowMock
    }
    
    func makeCheckoutFlow(userId: UserId, product: ShowcaseProduct) -> CheckoutFlow {
        checkoutUserId = userId
        checkoutProduct = product
        
        return checkoutFlowMock
    }
}
