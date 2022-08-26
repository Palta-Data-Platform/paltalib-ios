//
//  SubscriptionsServiceMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 27/05/2022.
//

import Foundation
@testable import PaltaLibPayments

final class SubscriptionsServiceMock: SubscriptionsService {
    var ids: Set<UUID>?
    var userId: UserId?
    var traceId: UUID?
    var result: Result<[Subscription], PaymentsError>?
    
    func getSubscriptions(
        with ids: Set<UUID>,
        for userId: UserId,
        traceId: UUID,
        completion: @escaping (Result<[Subscription], PaymentsError>) -> Void
    ) {
        self.ids = ids
        self.traceId = traceId
        self.userId = userId
        
        if let result = result {
            completion(result)
        }
    }
}
