//
//  PaymentQueueInteractor.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 30/08/2022.
//

import Foundation
import StoreKit

protocol PaymentQueueInteractor {
    func purchase(_ product: ShowcaseProduct, orderId: UUID, completion: @escaping (Result<(String, String), PaymentsError>) -> Void)
    func close(_ transaction: String)
}

final class PaymentQueueInteractorImpl: PaymentQueueInteractor {
    private let paymentQueue: SKPaymentQueue
    
    private let queueObserver = PaymentQueueObserver()
    
    private var completionHandlers: [String: (Result<(String, String), PaymentsError>) -> Void] = [:]
    
    init(paymentQueue: SKPaymentQueue) {
        self.paymentQueue = paymentQueue
        
        setupListener()
    }
    
    func purchase(_ product: ShowcaseProduct, orderId: UUID, completion: @escaping (Result<(String, String), PaymentsError>) -> Void) {
        guard completionHandlers[product.skProduct.productIdentifier] == nil else {
            completion(.failure(.purchaseInProgress))
            return
        }
        
        completionHandlers[product.skProduct.productIdentifier] = completion
        
        let payment = SKMutablePayment(product: product.skProduct)
        payment.applicationUsername = orderId.uuidString
        
        paymentQueue.add(payment)
    }
    
    func close(_ transaction: String) {
        guard let transaction = paymentQueue.transactions.first(where: { $0.stableId == transaction }) else {
            return
        }
        
        paymentQueue.finishTransaction(transaction)
    }
    
    private func setupListener() {
        queueObserver.listener = { [weak self] in
            self?.handleUpdate(for: $0, state: $1, transactionId: $2, stableTransactionId: $3, error: $4)
        }
        
        paymentQueue.add(queueObserver)
    }
    
    private func handleUpdate(
        for productIdentifier: String,
        state: SKPaymentTransactionState,
        transactionId: String?,
        stableTransactionId: String?,
        error: Error?
    ) {
        switch state {
        case .deferred, .purchasing:
            // Wait, do nothing
            break
        case .failed:
            failPurchase(for: productIdentifier, with: error)
        case .purchased, .restored:
            completePurchase(for: productIdentifier, transactionId: transactionId, stableTransactionId: stableTransactionId)
        @unknown default:
            assertionFailure()
        }
    }
    
    private func failPurchase(for productIdentifier: String, with error: Error?) {
        let skError = error as? SKError
        let code = skError?.code
        
        let paymentsError: PaymentsError =
        error as? PaymentsError
        ?? (code == .paymentCancelled ? .cancelledByUser : .storeKitError(code))
        
        completionHandlers[productIdentifier]?(.failure(paymentsError))
        completionHandlers[productIdentifier] = nil
    }
    
    private func completePurchase(for productIdentifier: String, transactionId: String?, stableTransactionId: String?) {
        guard let transactionId = transactionId, let stableTransactionId = stableTransactionId else {
            failPurchase(for: productIdentifier, with: PaymentsError.unknownError)
            return
        }
        
        if let completionHandler = completionHandlers[productIdentifier] {
            completionHandler(.success((transactionId, stableTransactionId)))
        } else {
            close(transactionId)
        }

        completionHandlers[productIdentifier] = nil
    }
}

private final class PaymentQueueObserver: NSObject, SKPaymentTransactionObserver {
    var listener: ((String, SKPaymentTransactionState, String?, String?, Error?) -> Void)?
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach {
            listener?(
                $0.payment.productIdentifier,
                $0.transactionState,
                $0.transactionIdentifier,
                $0.stableId,
                $0.error
            )
        }
    }
}

extension SKPaymentTransaction {
    var stableId: String? {
        original?.transactionIdentifier ?? transactionIdentifier
    }
}
