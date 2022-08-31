//
//  CheckoutFlow.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 30/08/2022.
//

import Foundation

protocol CheckoutFlow {
    func start(product: Product, userId: UserId, completion: @escaping (Result<PaidFeatures, PaymentsError>) -> Void)
}

final class CheckoutFlowImpl: CheckoutFlow {
    private let lock = NSRecursiveLock()
    private let traceId = UUID()
    private var isInProgress = false
    
    private let checkoutService: CheckoutService
    private let featuresService: PaidFeaturesService
    private let paymentQueueInteractor: PaymentQueueInteractor
    
    init(
        checkoutService: CheckoutService,
        featuresService: PaidFeaturesService,
        paymentQueueInteractor: PaymentQueueInteractor
    ) {
        self.checkoutService = checkoutService
        self.featuresService = featuresService
        self.paymentQueueInteractor = paymentQueueInteractor
    }
    
    func start(
        product: Product,
        userId: UserId,
        completion: @escaping (Result<PaidFeatures, PaymentsError>) -> Void
    ) {
        lock.lock()
        defer { lock.lock() }
        
        guard !isInProgress else {
            return
        }
        
        isInProgress = true
        
        checkoutService.startCheckout(userId: userId, traceId: traceId) { [weak self] result in
            switch result {
            case .success(let orderId):
                self?.purchase(product, for: orderId, userId: userId, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func purchase(
        _ product: Product,
        for orderId: UUID,
        userId: UserId,
        completion: @escaping (Result<PaidFeatures, PaymentsError>) -> Void
    ) {
        paymentQueueInteractor.purchase(product) { [weak self] result in
            switch result {
            case .success:
                self?.completeCheckout(for: orderId, userId: userId, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func completeCheckout(
        for orderId: UUID,
        userId: UserId,
        completion: @escaping (Result<PaidFeatures, PaymentsError>) -> Void
    ) {
        guard let receiptData = Bundle.main.appStoreReceiptURL.flatMap({ try? Data(contentsOf: $0) }) else {
            completion(.failure(.noReceipt))
            return
        }
        
        checkoutService.completeCheckout(orderId: orderId, receiptData: receiptData, traceId: traceId) { [weak self] result in
            switch result {
            case .success:
                self?.getCheckout(for: orderId, userId: userId, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func getCheckout(
        for orderId: UUID,
        userId: UserId,
        completion: @escaping (Result<PaidFeatures, PaymentsError>) -> Void
    ) {
        checkoutService.getCheckout(orderId: orderId, traceId: traceId) { [weak self] result in
            switch result {
            case .success(let checkoutState):
                self?.getFeatures(for: userId, after: checkoutState, orderId: orderId, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func getFeatures(
        for userId: UserId,
        after checkoutState: CheckoutState,
        orderId: UUID,
        completion: @escaping (Result<PaidFeatures, PaymentsError>) -> Void
    ) {
        switch checkoutState {
        case .completed:
            featuresService.getPaidFeatures(for: userId, completion: completion)
        case .processing:
            completion(.failure(.flowNotCompleted))
        case .failed, .cancelled:
            completion(.failure(.flowFailed(orderId)))
        }
    }
}
