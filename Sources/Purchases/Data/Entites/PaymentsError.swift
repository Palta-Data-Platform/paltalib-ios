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
    
    var localizedDescription: String {
        switch self {
        case .invalidKey:
            return "PaltaLib: Payments: Invalid API key error."
        case .noUserId:
            return "PaltaLib: Payments: Log in user first."
        case .serverError:
            return "PaltaLib: Payments: Server error. Please try again later."
        case .sdkError(let error):
            return "PaltaLib: Payments: SDK error. Please contact developer. \n\(error)"
        case .networkError(let error):
            return "PaltaLib: Payments: Network error. Please try again later. \n\(error)"
        case .cancelledByUser:
            return "PaltaLib: Payments: Operation cancelled by user"
        case .storeKitError(let error):
            return "PaltaLib: Payments: Error occured within StoreKit\(error.map { ":\n\($0)" } ?? "")"
        case .timedOut:
            return "PaltaLib: Payments: Operation timed out"
        case .purchaseInProgress:
            return "PaltaLib: Payments: You already have in progress purchase for this product id"
        case .noReceipt:
            return "PaltaLib: Payments: No App Store receipt found. Please verify that you're running App Store version of the app."
        case .flowFailed(let orderId):
            return "PaltaLib: Payments: Your payment flow has failed. Please contact PB team for details. Order id: \(orderId)"
        case .flowNotCompleted:
            return "PaltaLib: Payments: Your payment completed successfully however we didn't grant you features yet. Try to call .getPaidFeatures later"
        }
    }
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
        print(localizedDescription)
    }
}
