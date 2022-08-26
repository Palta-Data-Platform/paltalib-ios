//
//  ShowcaseServiceMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 22/08/2022.
//

import Foundation
@testable import PaltaLibPayments

final class ShowcaseServiceMock: ShowcaseService {
    var userId: UserId?
    var traceId: UUID?
    var result: Result<[PricePoint], PaymentsError>?
    
    func getProductIds(for userId: UserId, traceId: UUID, _ completion: @escaping (Result<[PricePoint], PaymentsError>) -> Void) {
        self.userId = userId
        self.traceId = traceId
        
        if let result = result {
            completion(result)
        }
    }
}
