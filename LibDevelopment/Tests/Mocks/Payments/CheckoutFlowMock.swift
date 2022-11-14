//
//  CheckoutFlowMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 14/11/2022.
//

import Foundation
@testable import PaltaLibPayments

final class CheckoutFlowMock: CheckoutFlow {
    var result: Result<PaidFeatures, PaymentsError>?
    
    func start(completion: @escaping (Result<PaidFeatures, PaymentsError>) -> Void) {
        if let result = result {
            completion(result)
        }
    }
}
