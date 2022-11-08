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

    let paidFeaturesMock = PaidFeaturesServiceMock()
    let showcaseFlowMock = ShowcaseFlowMock()
    
    var paidFeaturesService: PaidFeaturesService {
        paidFeaturesMock
    }
    
    func makeShowcaseFlow(userId: UserId) -> ShowcaseFlow {
        showcaseUserId = userId
        return showcaseFlowMock
    }
    
    func makeCheckoutFlow(userId: UserId, product: ShowcaseProduct) -> CheckoutFlow {
        fatalError()
    }
}
