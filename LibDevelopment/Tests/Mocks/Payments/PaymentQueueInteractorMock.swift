//
//  PaymentQueueInteractorMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 06/09/2022.
//

import Foundation
@testable import PaltaLibPayments

final class PaymentQueueInteractorMock: PaymentQueueInteractor {
    var product: Product?
    var orderId: UUID?
    
    var result: Result<String, PaymentsError>?
    
    func purchase(_ product: Product, orderId: UUID, completion: @escaping (Result<String, PaymentsError>) -> Void) {
        if let result = result {
            completion(result)
        }
    }
}
