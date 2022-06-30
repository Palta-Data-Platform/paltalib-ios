//
//  PaltaAnalytics2.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 29/06/2022.
//

import Foundation

public class PaltaAnalytics2 {
    public static func initiate(with stack: Stack) {
        _shared = PaltaAnalytics2(assembly: AnalyticsAssembly2(stack: stack))
    }
    
    public static var shared: PaltaAnalytics2 {
        guard let configuredInstance = _shared else {
            fatalError("Attempt to access PaltaAnalytics without setting up")
        }
        return configuredInstance
    }
    
    private static var _shared: PaltaAnalytics2?
    
    let assembly: AnalyticsAssembly2
    
    init(assembly: AnalyticsAssembly2) {
        self.assembly = assembly
    }
    
    func setAPIKey(_ apiKey: String) {
        
    }
}
