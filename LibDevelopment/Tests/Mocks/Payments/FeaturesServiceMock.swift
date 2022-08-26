//
//  FeaturesServiceMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 27/05/2022.
//

import Foundation
@testable import PaltaLibPayments

final class FeaturesServiceMock: FeaturesService {
    var userId: UserId?
    var traceId: UUID?
    var result: Result<[Feature], PaymentsError>?
    
    func getFeatures(
        for userId: UserId,
        traceId: UUID,
        completion: @escaping (Result<[Feature], PaymentsError>) -> Void
    ) {
        self.userId = userId
        self.traceId = traceId
        
        if let result = result {
            completion(result)
        }
    }
}
