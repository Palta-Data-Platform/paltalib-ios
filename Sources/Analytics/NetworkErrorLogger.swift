//
//  NetworkErrorLogger.swift
//  
//
//  Created by Vyacheslav Beltyukov on 05/04/2023.
//

import Foundation
import PaltaLibCore

protocol NetworkErrorLogger {
    func logNetworkError<T: Codable>(_ error: NetworkErrorWithResponse<T>)
    func getTenRecentErrors() -> [String]
}

final class NetworkErrorLoggerImpl: NetworkErrorLogger {
    private static func newArray(with elements: [String] = []) -> [String] {
        var array: [String] = []
        array.reserveCapacity(50)
        array[elements.suffix(10).indices] = elements.suffix(10)
        return array
    }
    
    private static func readOrCreateArray() -> [String] {
        UserDefaults.standard
            .array(forKey: "pb_legacy_network_errors")?
            .compactMap { $0 as? String }
        ?? newArray()
    }
    
    private var errors: [String] = NetworkErrorLoggerImpl.readOrCreateArray() {
        didSet {
            UserDefaults.standard.set(errors, forKey: "pb_legacy_network_errors")
            
            if errors.count > 40 {
                errors = Self.newArray(with: errors)
            }
        }
    }
    
    private let lock = NSRecursiveLock()
    
    func logNetworkError<T: Codable>(_ error: NetworkErrorWithResponse<T>) {
        lock.lock()
        switch error {
        case .badRequest:
            errors.append("bad request")
        case .invalidStatusCode(let code, _):
            errors.append("invalid code - \(code)")
        case .other(let error):
            errors.append("other - \(error.localizedDescription.prefix(100))")
        case .noData:
            errors.append("no data")
        case .urlError(let error):
            errors.append("url error - \(error.code.rawValue)")
        case .decodingError(let decodingError):
            errors.append("decoding error - \(decodingError.map { $0.localizedDescription.prefix(100) } ?? "")")
        }
        lock.unlock()
    }
    
    func getTenRecentErrors() -> [String] {
        lock.lock()
        defer { lock.unlock() }
        
        return Array(errors.suffix(10))
    }
}
