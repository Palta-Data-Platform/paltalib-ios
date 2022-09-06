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
    private let product: Product
    
    private let checkoutService: CheckoutService
    private let featuresService: PaidFeaturesService
    private let paymentQueueInteractor: PaymentQueueInteractor
    
    init(
        environment: Environment,
        userId: UserId,
        product: Product,
        checkoutService: CheckoutService,
        featuresService: PaidFeaturesService,
        paymentQueueInteractor: PaymentQueueInteractor
    ) {
        self.environment = environment
        self.userId = userId
        self.product = product
        self.checkoutService = checkoutService
        self.featuresService = featuresService
        self.paymentQueueInteractor = paymentQueueInteractor
    }
    
    func start( completion: @escaping (Result<PaidFeatures, PaymentsError>) -> Void) {
        lock.lock()
        defer { lock.lock() }
        
        guard !isInProgress else {
            return
        }
        
        logStep("Start checkout", data: ["productId": product.productIdentifier, "userId": userId.stringValue])
        
        isInProgress = true
        
        checkoutService.startCheckout(userId: userId, traceId: traceId) { [self] result in
            switch result {
            case .success(let orderId):
                purchase(with: orderId, completion: completion)
            case .failure(let error):
                logError(error, "Start checkout failed")
                completion(.failure(error))
            }
        }
    }
    
    private func purchase(
        with orderId: UUID,
        completion: @escaping (Result<PaidFeatures, PaymentsError>) -> Void
    ) {
        logStep(
            "App Store purchase started",
            data: ["productId": product.productIdentifier, "userId": userId.stringValue]
        )
        
        paymentQueueInteractor.purchase(product, orderId: orderId) { [self] result in
            switch result {
            case .success(let transactionId):
                completeCheckout(for: orderId, transactionId: transactionId, completion: completion)
            case .failure(let error):
                failPurchase(orderId: orderId, with: error, completion: completion)
                completion(.failure(error))
            }
        }
    }
    
    private func completeCheckout(
        for orderId: UUID,
        transactionId: String,
        completion: @escaping (Result<PaidFeatures, PaymentsError>) -> Void
    ) {
        logStep("App Store purchase successful. Retrieving receipt...")
        
        guard let receiptData = Bundle.main.appStoreReceiptURL.flatMap({ try? Data(contentsOf: $0) }) else {
            failPurchase(orderId: orderId, with: .noReceipt, completion: completion)
            return
        }
        
        logStep("Receipt retrieved. Completing checkout...")
        
        checkoutService.completeCheckout(orderId: orderId, receiptData: receiptData, transactionId: transactionId, traceId: traceId) { [self] result in
            switch result {
            case .success:
                getCheckout(for: orderId, completion: completion)
            case .failure(let error):
                logError(error, "Checkout complete failed")
                completion(.failure(error))
            }
        }
    }
    
    private func getCheckout(
        for orderId: UUID,
        completion: @escaping (Result<PaidFeatures, PaymentsError>) -> Void
    ) {
        logStep("Getting checkout state...")
        
        checkoutService.getCheckout(orderId: orderId, traceId: traceId) { [self] result in
            switch result {
            case .success(let checkoutState):
                getFeatures(after: checkoutState, orderId: orderId, completion: completion)
            case .failure(let error):
                logError(error, "Get checkout failed")
                completion(.failure(error))
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
            logStep("Get checkout successful. Retrieving features")
            featuresService.getPaidFeatures(for: userId, completion: completion)
        case .processing:
            logError(.flowNotCompleted, "Received processing checkout status from backend")
            completion(.failure(.flowNotCompleted))
        case .failed, .cancelled:
            logError(.flowFailed(orderId), "Received failed checkout status from backend")
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
                event: "App Store purchase failed",
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