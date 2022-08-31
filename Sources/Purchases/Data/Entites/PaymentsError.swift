//
//  PaymentsError.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 20/05/2022.
//

import Foundation
import PaltaLibCore

public enum PaymentsError: Error {
    public static let unknownError: PaymentsError = .sdkError(.other(nil))
    
    case invalidKey
    case noUserId
    case cancelledByUser
    case timedOut
    case noReceipt
    case storeKitError(Error?)
    case serverError(Int)
    case sdkError(SDKError)
    case networkError(URLError)
    case purchaseInProgress
    case flowNotCompleted
    case flowFailed(UUID)
}

public enum SDKError: Error {
    case protocolError
    case validationError
    case noSuitablePlugin
    case decodingError(DecodingError?)
    case other(Error?)
}

extension PaymentsError {
    init(networkError: NetworkErrorWithoutResponse) {
        switch networkError {
        case .badRequest:
            self = .sdkError(.other(networkError))
            
        case .invalidStatusCode(let code, _) where code >= 500:
            self = .serverError(code)
            
        case .invalidStatusCode(let code, _) where code == 409:
            self = .sdkError(.protocolError)
            
        case .invalidStatusCode(let code, _) where code == 422:
            self = .sdkError(.validationError)
            
        case .invalidStatusCode(let code, _) where code == 401:
            self = .invalidKey
            
        case .invalidStatusCode:
            self = .sdkError(.other(networkError))
            
        case .other(let error):
            self = .sdkError(.other(error))
            
        case .noData:
            self = .serverError(0)
            
        case .urlError(let error):
            self = .networkError(error)
            
        case .decodingError(let error):
            self = .sdkError(.decodingError(error))
        }
    }
}

extension PaymentsError {
    func printLog() {
        switch self {
        case .invalidKey:
            print("PaltaLib: Payments: Invalid API key error.")
        case .noUserId:
            print("PaltaLib: Payments: Log in user first.")
        case .serverError:
            print("PaltaLib: Payments: Server error. Please try again later.")
        case .sdkError(let error):
            print("PaltaLib: Payments: SDK error. Please contact developer. \n\(error)")
        case .networkError(let error):
            print("PaltaLib: Payments: Network error. Please try again later. \n\(error)")
        case .cancelledByUser:
            print("PaltaLib: Payments: Operation cancelled by user")
        case .storeKitError(let error):
            print("PaltaLib: Payments: Error occured within StoreKit\(error.map { ":\n\($0)" } ?? "")")
        case .timedOut:
            print("PaltaLib: Payments: Operation timed out")
        case .purchaseInProgress:
            print("PaltaLib: Payments: You already have in progress purchase for this product id")
        case .noReceipt:
            print("PaltaLib: Payments: No App Store receipt found. Please verify that you're running App Store version of the app.")
        case .flowFailed(let orderId):
            print("PaltaLib: Payments: Your payment flow has failed. Please contact PB team for details. Order id: \(orderId)")
        case .flowNotCompleted:
            print("PaltaLib: Payments: Your payment completed successfully however we didn't grant you features yet. Try to call .getPaidFeatures later")
        }
    }
}
