//
//  PaymentsAssembly.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 27/05/2022.
//

import Foundation
import PaltaLibCore

protocol PaymentsAssembly {
    var paidFeaturesService: PaidFeaturesService { get }
    
    func makeShowcaseFlow(userId: UserId) -> ShowcaseFlow
    func makeCheckoutFlow(userId: UserId, product: ShowcaseProduct) -> CheckoutFlow
    func makeCheckoutFlow(userId: UserId, product: ShowcaseProduct, logging: @escaping (String) -> Void) -> CheckoutFlow
}

final class RealPaymentsAssembly: PaymentsAssembly {
    var paidFeaturesService: PaidFeaturesService {
        webPaymentsAssembly.paidFeaturesService
    }
    
    private let coreAssembly: CoreAssembly
    private let webPaymentsAssembly: WebPaymentsAssembly
    private let showcaseAssembly: ShowcaseAssembly
    private let checkoutAssembly: CheckoutAssembly
    
    private init(
        coreAssembly: CoreAssembly,
        webPaymentsAssembly: WebPaymentsAssembly,
        showcaseAssembly: ShowcaseAssembly,
        checkoutAssembly: CheckoutAssembly
    ) {
        self.coreAssembly = coreAssembly
        self.webPaymentsAssembly = webPaymentsAssembly
        self.showcaseAssembly = showcaseAssembly
        self.checkoutAssembly = checkoutAssembly
    }
    
    func makeShowcaseFlow(userId: UserId) -> ShowcaseFlow {
        showcaseAssembly.makeShowcaseFlow(userId: userId)
    }
    
    func makeCheckoutFlow(userId: UserId, product: ShowcaseProduct) -> CheckoutFlow {
        checkoutAssembly.makeCheckoutFlow(userId: userId, product: product)
    }
    
    func makeCheckoutFlow(userId: UserId, product: ShowcaseProduct, logging: @escaping (String) -> Void) -> CheckoutFlow {
        checkoutAssembly.makeCheckoutFlow(userId: userId, product: product, logging: logging)
    }
}

extension RealPaymentsAssembly {
    convenience init(apiKey: String, environment: Environment) {
        let core = CoreAssembly()
        let webPayments = WebPaymentsAssembly(apiKey: apiKey, environment: environment, coreAssembly: core)
        let showcaseAssembly = ShowcaseAssemblyImpl(environment: environment, coreAssembly: core)
        let checkoutAssembly = CheckoutAssemblyImpl(
            environment: environment,
            coreAssembly: core,
            webPaymentsAssembly: webPayments
        )
        
        self.init(
            coreAssembly: core,
            webPaymentsAssembly: webPayments,
            showcaseAssembly: showcaseAssembly,
            checkoutAssembly: checkoutAssembly
        )
    }
}
