//
//  PaymentQueueObserver.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 24/08/2022.
//

import Foundation
import StoreKit

protocol PaymentQueueObserver {
    
}

public final class PaymentQueueObserverImpl: NSObject, PaymentQueueObserver {
}

extension PaymentQueueObserverImpl: SKPaymentTransactionObserver {
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach {
            $0.transactionState == .deferred
        }
    }
}
