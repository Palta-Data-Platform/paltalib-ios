//
//  CheckoutAssembly.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 31/08/2022.
//

import Foundation
import PaltaLibCore

protocol CheckoutAssembly {
    func makeCheckoutFlow(userId: UserId, product: ShowcaseProduct) -> CheckoutFlow
    func makeCheckoutFlow(userId: UserId, product: ShowcaseProduct, logging: @escaping (String) -> Void) -> CheckoutFlow
}

final class CheckoutAssemblyImpl: CheckoutAssembly {
    let environment: Environment
    let checkoutService: CheckoutService
    let paymentQueueInteractor: PaymentQueueInteractor
    let webPaymentsAssembly: WebPaymentsAssembly
    
    init(
        environment: Environment,
        checkoutService: CheckoutService,
        paymentQueueInteractor: PaymentQueueInteractor,
        webPaymentsAssembly: WebPaymentsAssembly
    ) {
        self.environment = environment
        self.checkoutService = checkoutService
        self.paymentQueueInteractor = paymentQueueInteractor
        self.webPaymentsAssembly = webPaymentsAssembly
    }
    
    func makeCheckoutFlow(userId: UserId, product: ShowcaseProduct) -> CheckoutFlow {
        CheckoutFlowImpl(
            logging: { _ in },
            environment: environment,
            userId: userId,
            product: product,
            checkoutService: checkoutService,
            featuresService: webPaymentsAssembly.paidFeaturesService,
            paymentQueueInteractor: paymentQueueInteractor,
            receiptProvider: ReceiptProviderImpl()
        )
    }
    
    func makeCheckoutFlow(userId: UserId, product: ShowcaseProduct, logging: @escaping (String) -> Void) -> CheckoutFlow {
        CheckoutFlowImpl(
            logging: logging,
            environment: environment,
            userId: userId,
            product: product,
            checkoutService: checkoutService,
            featuresService: webPaymentsAssembly.paidFeaturesService,
            paymentQueueInteractor: paymentQueueInteractor,
            receiptProvider: ReceiptProviderImpl()
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
            environment: environment,
            checkoutService: checkoutService,
            paymentQueueInteractor: paymentQueueInteractor,
            webPaymentsAssembly: webPaymentsAssembly
        )
    }
}
