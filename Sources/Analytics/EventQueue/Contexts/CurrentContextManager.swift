//
//  CurrentContextManager.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 22/06/2022.
//

import Foundation

protocol ContextModifier {
    func editContext<Context: BatchContext>(_ editor: (inout Context) -> Void)
    func stripContexts(excluding contextIds: Set<UUID>)
}

protocol CurrentContextProvider {
    var context: BatchContext { get }
    var currentContextId: UUID { get }
}

final class CurrentContextManager: ContextModifier, CurrentContextProvider {
    var context: BatchContext {
        lock.lock()
        defer { lock.unlock() }
        
        if let context = _context {
            return context
        }
        
        let context = generateEmptyContext()
        _context = context
        return context
    }
    
    var currentContextId: UUID {
        lock.lock()
        defer { lock.unlock() }
        return _currentContextId
    }
    
    private var _currentContextId = UUID()
    
    private var _context: BatchContext?
    
    private let lock = NSRecursiveLock()
    
    private let stack: Stack
    private let storage: ContextStorage
    
    init(stack: Stack, storage: ContextStorage) {
        self.stack = stack
        self.storage = storage
    }
    
    func editContext<Context: BatchContext>(_ editor: (inout Context) -> Void) {
        lock.lock()
        var context = (_context ?? generateEmptyContext()) as! Context
        editor(&context)
        
        _currentContextId = UUID()
        do {
            try storage.saveContext(context, with: currentContextId)
        } catch {
            print("PaltaLib: Analytics: Error saving context: \(context)")
        }
        
        _context = context
        lock.unlock()
    }
    
    func stripContexts(excluding contextIds: Set<UUID>) {
        do {
            try storage.stripContexts(excluding: contextIds)
        } catch {
            print("PaltaLib: Analytics: Error stripping contexts: \(context)")
        }
    }
    
    private func generateEmptyContext() -> BatchContext {
        stack.context.init()
    }
}
