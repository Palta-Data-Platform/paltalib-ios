//
//  PaymentQueueInteractorMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 06/09/2022.
//

import Foundation
@testable import PaltaLibPayments

final class PaymentQueueInteractorMock: PaymentQueueInteractor {
    var product: ShowcaseProduct?
    var orderId: UUID?
    var closedTransactions: Set<String> = []
    
    var result: Result<String, PaymentsError>?
    
    func purchase(_ product: ShowcaseProduct, orderId: UUID, completion: @escaping (Result<String, PaymentsError>) -> Void) {
        self.product = product
        self.orderId = orderId
        
        if let result = result {
            completion(result)
        }
    }
    
    func close(_ transaction: String) {
        closedTransactions.insert(transaction)
    }
}
