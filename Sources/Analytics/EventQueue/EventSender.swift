//
//  EventSender.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 04.04.2022.
//

import Foundation

enum EventSendError: Error {
    case timeout
    case noInternet
    case serverError
    case badRequest
    case unknown

    var requiresRetry: Bool {
        switch self {
        case .timeout, .noInternet, .serverError:
            return true
        case .badRequest, .unknown:
            return false
        }
    }
}

protocol EventSender {
    func sendEvents(_ events: [Event], completion: @escaping (Result<(), EventSendError>) -> Void)
}
