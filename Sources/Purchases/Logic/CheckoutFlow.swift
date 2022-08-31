//
//  CheckoutFlow.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 30/08/2022.
//

import Foundation

protocol CheckoutFlow {
    func start(completion: @escaping (Result<PaidFeatures, PaymentsError>) -> Void)
}

final class CheckoutFlowImpl: CheckoutFlow {
    private let lock = NSRecursiveLock()
    private let traceId = UUID()
    private var isInProgress = false
    
    private let userId: UserId
    private let product: Product
    
    private let checkoutService: CheckoutService
    private let featuresService: PaidFeaturesService
    private let paymentQueueInteractor: PaymentQueueInteractor
    
    init(
        userId: UserId,
        product: Product,
        checkoutService: CheckoutService,
        featuresService: PaidFeaturesService,
        paymentQueueInteractor: PaymentQueueInteractor
    ) {
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
        
        isInProgress = true
        
        checkoutService.startCheckout(userId: userId, traceId: traceId) { [weak self] result in
            switch result {
            case .success(let orderId):
                self?.purchase(with: orderId, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func purchase(
        with orderId: UUID,
        completion: @escaping (Result<PaidFeatures, PaymentsError>) -> Void
    ) {
        paymentQueueInteractor.purchase(product) { [weak self] result in
            switch result {
            case .success:
                self?.completeCheckout(for: orderId, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func completeCheckout(
        for orderId: UUID,
        completion: @escaping (Result<PaidFeatures, PaymentsError>) -> Void
    ) {
        guard let receiptData = Bundle.main.appStoreReceiptURL.flatMap({ try? Data(contentsOf: $0) }) else {
            completion(.failure(.noReceipt))
            return
        }
        
        checkoutService.completeCheckout(orderId: orderId, receiptData: receiptData, traceId: traceId) { [weak self] result in
            switch result {
            case .success:
                self?.getCheckout(for: orderId, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func getCheckout(
        for orderId: UUID,
        completion: @escaping (Result<PaidFeatures, PaymentsError>) -> Void
    ) {
        checkoutService.getCheckout(orderId: orderId, traceId: traceId) { [weak self] result in
            switch result {
            case .success(let checkoutState):
                self?.getFeatures(after: checkoutState, orderId: orderId, completion: completion)
            case .failure(let error):
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
            featuresService.getPaidFeatures(for: userId, completion: completion)
        case .processing:
            completion(.failure(.flowNotCompleted))
        case .failed, .cancelled:
            completion(.failure(.flowFailed(orderId)))
        }
    }
}
