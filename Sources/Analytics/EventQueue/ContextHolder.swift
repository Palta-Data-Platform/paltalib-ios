//
//  ContextHolder.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 07/06/2022.
//

import Foundation

protocol ContextHolder {
    var context: BatchContext { get }
}

protocol ContextModifier: ContextHolder {
    func editContext(_ editor: (inout BatchContext) -> Void)
}

final class ContextHolderImpl: ContextModifier {
    static func loadContext() -> BatchContext {
        fatalError()
    }
    
    var context: BatchContext {
        lock.lock()
        defer { lock.unlock() }
        
        if let context = _context {
            return context
        }
        
        let context = Self.loadContext()
        _context = context
        return context
    }
    
    private var _context: BatchContext?
    
    private let lock = NSRecursiveLock()
    
    func editContext(_ editor: (inout BatchContext) -> Void) {
        lock.lock()
        var context = _context ?? Self.loadContext()
        editor(&context)
        _context = context
        lock.unlock()
    }
}
