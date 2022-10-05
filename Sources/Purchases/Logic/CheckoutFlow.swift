//
//  CheckoutFlow.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 30/08/2022.
//

import Foundation
import PaltaLibCore

protocol CheckoutFlow {
    func start(completion: @escaping (Result<PaidFeatures, PaymentsError>) -> Void)
}

final class CheckoutFlowImpl: CheckoutFlow {
    private let lock = NSRecursiveLock()
    private let traceId = UUID()
    private var isInProgress = false
    
    private let environment: Environment
    private let userId: UserId
    private let product: ShowcaseProduct
    
    private let checkoutService: CheckoutService
    private let featuresService: PaidFeaturesService
    private let paymentQueueInteractor: PaymentQueueInteractor
    private let receiptProvider: ReceiptProvider
    
    init(
        environment: Environment,
        userId: UserId,
        product: ShowcaseProduct,
        checkoutService: CheckoutService,
        featuresService: PaidFeaturesService,
        paymentQueueInteractor: PaymentQueueInteractor,
        receiptProvider: ReceiptProvider
    ) {
        self.environment = environment
        self.userId = userId
        self.product = product
        self.checkoutService = checkoutService
        self.featuresService = featuresService
        self.paymentQueueInteractor = paymentQueueInteractor
        self.receiptProvider = receiptProvider
    }
    
    func start(completion: @escaping (Result<PaidFeatures, PaymentsError>) -> Void) {
        lock.lock()
        defer { lock.lock() }
        
        guard !isInProgress else {
            return
        }
        
        logStep("start_checkout", data: ["productId": product.skProduct.productIdentifier, "userId": userId.stringValue])
        
        isInProgress = true
        
        checkoutService.startCheckout(userId: userId, ident: product.ident, traceId: traceId) { [self] result in
            switch result {
            case .success(let orderId):
                purchase(with: orderId, completion: completion)
            case .failure(let error):
                logError(error, "start_checkout_failed")
                completion(.failure(error))
            }
        }
    }
    
    private func purchase(
        with orderId: UUID,
        completion: @escaping (Result<PaidFeatures, PaymentsError>) -> Void
    ) {
        logStep(
            "appstore_purchase_started",
            data: ["productId": product.skProduct.productIdentifier, "userId": userId.stringValue]
        )
        
        paymentQueueInteractor.purchase(product, orderId: orderId) { [self] result in
            switch result {
            case .success(let transactionId):
                completeCheckout(for: orderId, transactionId: transactionId, completion: completion)
            case .failure(let error):
                failPurchase(orderId: orderId, with: error, completion: completion)
            }
        }
    }
    
    private func completeCheckout(
        for orderId: UUID,
        transactionId: String,
        completion: @escaping (Result<PaidFeatures, PaymentsError>) -> Void
    ) {
        logStep("retrieving_receipt")
        
        guard let receiptData = receiptProvider.getReceiptData() else {
            failPurchase(orderId: orderId, with: .noReceipt, completion: completion)
            return
        }
        
        logStep("receipt_retrieved")
        
        checkoutService.completeCheckout(orderId: orderId, receiptData: receiptData, transactionId: transactionId, traceId: traceId) { [self] result in
            switch result {
            case .success:
                paymentQueueInteractor.close(transactionId)
                getCheckout(for: orderId, completion: completion)
            case .failure(let error):
                logError(error, "Checkout complete failed")
                completion(.failure(.flowNotCompleted))
            }
        }
    }
    
    private func getCheckout(
        for orderId: UUID,
        completion: @escaping (Result<PaidFeatures, PaymentsError>) -> Void
    ) {
        logStep("get_checkout_state")
        
        checkoutService.getCheckout(orderId: orderId, traceId: traceId) { [self] result in
            switch result {
            case .success(let checkoutState):
                getFeatures(after: checkoutState, orderId: orderId, completion: completion)
            case .failure(let error):
                logError(error, "get_checkout_state_failed")
                completion(.failure(.flowNotCompleted))
            }
        }
    }
    
    private func getFeatures(
        after checkoutState: CheckoutState,
        orderId: UUID,
        completion: @escaping (Result<PaidFeatures, PaymentsError>) -> Void
    ) {
        switch checkoutState {
        case .completed:
            logStep("get_checkout_success")
            featuresService.getPaidFeatures(for: userId) { result in
                switch result {
                case .success:
                    completion(result)
                case .failure:
                    completion(.failure(.flowNotCompleted))
                }
            }
        case .processing:
            logError(.flowNotCompleted, "get_checkout_processing")
            completion(.failure(.flowNotCompleted))
        case .failed, .cancelled:
            logError(.flowFailed(orderId), "get_checkout_failed")
            completion(.failure(.flowFailed(orderId)))
        }
    }
    
    private func failPurchase(
        orderId: UUID,
        with error: PaymentsError,
        completion: @escaping (Result<PaidFeatures, PaymentsError>) -> Void
    ) {
        if environment == .dev {
            checkoutService.log(
                level: .error,
                event: "appstore_failed",
                data: ["error": error.localizedDescription],
                traceId: traceId
            )
        }
        
        checkoutService.failCheckout(orderId: orderId, traceId: traceId) { (_: Result<(), PaymentsError>) in
            completion(.failure(error))
        }
    }
    
    private func logError(_ error: PaymentsError, _ messageName: String) {
        guard environment == .dev else {
            return
        }
        
        checkoutService.log(
            level: .error,
            event: messageName,
            data: ["error": error.localizedDescription],
            traceId: traceId
        )
    }
    
    private func logStep(_ stepName: String, data: [String: Any]? = nil) {
        guard environment == .dev else {
            return
        }
        
        checkoutService.log(
            level: .info,
            event: stepName,
            data: nil,
            traceId: traceId
        )
    }
}
