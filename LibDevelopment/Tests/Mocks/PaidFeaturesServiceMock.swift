//
//  PaidFeaturesServiceMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 27/05/2022.
//

import Foundation
@testable import PaltaLibPayments

final class PaidFeaturesServiceMock: PaidFeaturesService {
    var userId: UserId?
    var result: Result<PaidFeatures, PaymentsError>?
    
    func getPaidFeatures(
        for userId: UserId,
        completion: @escaping (Result<PaidFeatures, PaymentsError>) -> Void
    ) {
        self.userId = userId
        
        if let result = result {
            completion(result)
        }
    }
}
