//
//  PaltaAnalytics.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 29/06/2022.
//

import Foundation
import PaltaLibAnalyticsModel

public class PaltaAnalytics {
    private static var stack: Stack?
    private static let lock = NSRecursiveLock()

    public static func initiate(with stack: Stack) {
        self.stack = stack
    }
    
    public static var shared: PaltaAnalytics {
        lock.lock()
        defer { lock.unlock() }

        if let configuredInstance = _shared {
            return configuredInstance
        }
        
        guard let stack = stack else {
            fatalError("Attempt to access PaltaAnalytics without setting up")
        }
        
        let shared = PaltaAnalytics(assembly: AnalyticsAssembly(stack: stack))
        _shared = shared
        
        return shared
    }
    
    private static var _shared: PaltaAnalytics?
    
    let assembly: AnalyticsAssembly
    
    init(assembly: AnalyticsAssembly) {
        self.assembly = assembly
    }
}
