//
//  PurchasePluginResult.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 11/05/2022.
//

import Foundation

public enum PurchasePluginResult<Success, Failure: Error> {
    /// Operation successfuly completed.
    case success(Success)
    
    /// Plugin handled input, but operation failed with error. Pass failure to user.
    case failure(Failure)
    
    /// Passed input can't be handled by this plugin. Pass control to next plugin.
    case notSupported
    
    public init(result: Result<Success, Failure>) {
        switch result {
        case .success(let success):
            self = .success(success)
            
        case .failure(let error):
            self = .failure(error)
        }
    }
    
    var result: Result<Success, Failure>? {
        switch self {
        case .success(let success):
            return .success(success)
        case .failure(let error):
            return .failure(error)
        case .notSupported:
            return nil
        }
    }
}
