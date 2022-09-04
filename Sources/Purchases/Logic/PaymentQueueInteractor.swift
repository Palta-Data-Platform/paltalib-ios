//
//  PaymentQueueInteractor.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 30/08/2022.
//

import Foundation
import StoreKit

protocol PaymentQueueInteractor {
    func purchase(_ product: Product, orderId: UUID, completion: @escaping (Result<(), PaymentsError>) -> Void)
}

final class PaymentQueueInteractorImpl: PaymentQueueInteractor {
    private let paymentQueue: SKPaymentQueue
    
    private let queueObserver = PaymentQueueObserver()
    
    private var completionHandlers: [String: (Result<(), PaymentsError>) -> Void] = [:]
    
    init(paymentQueue: SKPaymentQueue) {
        self.paymentQueue = paymentQueue
        
        setupListener()
    }
    
    func purchase(_ product: Product, orderId: UUID, completion: @escaping (Result<(), PaymentsError>) -> Void) {
        guard completionHandlers[product.productIdentifier] == nil else {
            completion(.failure(.purchaseInProgress))
            return
        }
        
        guard let skProduct = product.originalEntity as? SKProduct else {
            completion(.failure(.sdkError(.noSuitablePlugin)))
            return
        }
        
        completionHandlers[product.productIdentifier] = completion
        
        let payment = SKMutablePayment(product: skProduct)
        payment.applicationUsername = orderId.uuidString
        paymentQueue.add(payment)
    }
    
    private func setupListener() {
        queueObserver.listener = { [weak self] in
            self?.handleUpdate(for: $0, state: $1, transactionId: $2, error: $3)
        }
        
        paymentQueue.add(queueObserver)
    }
    
    private func handleUpdate(
        for productIdentifier: String,
        state: SKPaymentTransactionState,
        transactionId: String?,
        error: Error?
    ) {
        switch state {
        case .deferred, .purchasing:
            // Wait, do nothing
            break
        case .failed:
            failPurchase(for: productIdentifier, with: error)
        case .purchased, .restored:
            completePurchase(for: productIdentifier)
        @unknown default:
            assertionFailure()
        }
    }
    
    private func failPurchase(for productIdentifier: String, with error: Error?) {
        completionHandlers[productIdentifier]?(.failure(.storeKitError(error)))
        completionHandlers[productIdentifier] = nil
    }
    
    private func completePurchase(for productIdentifier: String) {
        completionHandlers[productIdentifier]?(.success(()))
        completionHandlers[productIdentifier] = nil
    }
}

private final class PaymentQueueObserver: NSObject, SKPaymentTransactionObserver {
    var listener: ((String, SKPaymentTransactionState, String?, Error?) -> Void)?
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach {
            listener?($0.payment.productIdentifier, $0.transactionState, $0.transactionIdentifier, $0.error)
        }
    }
}
