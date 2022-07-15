//
//  PaltaAnalytics.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 29/06/2022.
//

import Foundation
import PaltaLibAnalyticsModel

public class PaltaAnalytics {
    public static func initiate(with stack: Stack) {
        _shared = PaltaAnalytics(assembly: AnalyticsAssembly(stack: stack))
    }
    
    public static var shared: PaltaAnalytics {
        guard let configuredInstance = _shared else {
            fatalError("Attempt to access PaltaAnalytics without setting up")
        }
        return configuredInstance
    }
    
    private static var _shared: PaltaAnalytics?
    
    let assembly: AnalyticsAssembly
    
    init(assembly: AnalyticsAssembly) {
        self.assembly = assembly
    }
}
