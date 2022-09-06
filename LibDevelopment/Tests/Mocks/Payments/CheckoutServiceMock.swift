//
//  CheckoutServiceMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 06/09/2022.
//

import Foundation
@testable import PaltaLibPayments

final class CheckoutServiceMock: CheckoutService {
    var startUserId: UserId?
    var startTraceId: UUID?
    var startResult: Result<UUID, PaymentsError>?
    
    var completeOrderId: UUID?
    var completeReceiptData: Data?
    var completTransactionId: String?
    var completeTraceId: UUID?
    var completeResult: Result<(), PaymentsError>?
    
    var failOrderId: UUID?
    var failTraceId: UUID?
    var failResult: Result<(), PaymentsError>?
    
    var getOrderId: UUID?
    var getTraceId: UUID?
    var getResult: Result<CheckoutState, PaymentsError>?
    
    var logLevel: LogPayload.Level?
    var logEvent: String?
    var logData: [String: Any]?
    var logTraceId: UUID?
    
    func startCheckout(userId: UserId, traceId: UUID, completion: @escaping (Result<UUID, PaymentsError>) -> Void) {
        startUserId = userId
        startTraceId = traceId
        
        if let startResult = startResult {
            completion(startResult)
        }
    }
    
    func completeCheckout(
        orderId: UUID,
        receiptData: Data,
        transactionId: String,
        traceId: UUID,
        completion: @escaping (Result<(), PaymentsError>) -> Void
    ) {
        completeOrderId = orderId
        completeReceiptData = receiptData
        completTransactionId = transactionId
        completeTraceId = traceId
        
        if let completeResult = completeResult {
            completion(completeResult)
        }
    }
    
    func failCheckout(orderId: UUID, traceId: UUID, completion: @escaping (Result<(), PaymentsError>) -> Void) {
        failOrderId = orderId
        failTraceId = traceId
        
        if let failResult = failResult {
            completion(failResult)
        }
    }
    
    func getCheckout(orderId: UUID, traceId: UUID, completion: @escaping (Result<CheckoutState, PaymentsError>) -> Void) {
        getOrderId = orderId
        getTraceId = traceId
        
        if let getResult = getResult {
            completion(getResult)
        }
    }
    
    func log(level: LogPayload.Level, event: String, data: [String : Any]?, traceId: UUID) {
        logLevel = level
        logEvent = event
        logData = data
        logTraceId = traceId
    }
}
