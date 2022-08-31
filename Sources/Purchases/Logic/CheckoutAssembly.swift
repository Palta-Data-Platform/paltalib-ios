//
//  CheckoutAssembly.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 31/08/2022.
//

import Foundation
import PaltaLibCore

protocol CheckoutAssembly {
    func makeCheckoutFlow(userId: UserId, product: Product) -> CheckoutFlow
}

final class CheckoutAssemblyImpl: CheckoutAssembly {
    let checkoutService: CheckoutService
    let paymentQueueInteractor: PaymentQueueInteractor
    let webPaymentsAssembly: WebPaymentsAssembly
    
    init(
        checkoutService: CheckoutService,
        paymentQueueInteractor: PaymentQueueInteractor,
        webPaymentsAssembly: WebPaymentsAssembly
    ) {
        self.checkoutService = checkoutService
        self.paymentQueueInteractor = paymentQueueInteractor
        self.webPaymentsAssembly = webPaymentsAssembly
    }
    
    func makeCheckoutFlow(userId: UserId, product: Product) -> CheckoutFlow {
        CheckoutFlowImpl(
            userId: userId,
            product: product,
            checkoutService: checkoutService,
            featuresService: webPaymentsAssembly.paidFeaturesService,
            paymentQueueInteractor: paymentQueueInteractor
        )
    }
}

extension CheckoutAssemblyImpl {
    convenience init(
        environment: Environment,
        coreAssembly: CoreAssembly,
        webPaymentsAssembly: WebPaymentsAssembly
    ) {
        let checkoutService = CheckoutServiceImpl(
            environment: environment,
            httpClient: coreAssembly.httpClient
        )
        
        let paymentQueueInteractor = PaymentQueueInteractorImpl(paymentQueue: .default())
        
        self.init(
            checkoutService: checkoutService,
            paymentQueueInteractor: paymentQueueInteractor,
            webPaymentsAssembly: webPaymentsAssembly
        )
    }
}
