//
//  AnalyticsAssembly2.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 29/06/2022.
//

import Foundation
import PaltaLibCore

final class AnalyticsAssembly2 {
    let coreAssembly: CoreAssembly
    let analyticsCoreAssembly: AnalyticsCoreAssembly
    let eventQueueAssembly: EventQueue2Assembly
    
    init(
        coreAssembly: CoreAssembly,
        analyticsCoreAssembly: AnalyticsCoreAssembly,
        eventQueueAssembly: EventQueue2Assembly
    ) {
        self.coreAssembly = coreAssembly
        self.analyticsCoreAssembly = analyticsCoreAssembly
        self.eventQueueAssembly = eventQueueAssembly
    }
}

extension AnalyticsAssembly2 {
    convenience init(stack: Stack) {
        let coreAssembly = CoreAssembly()
        let analyticsCoreAssembly = AnalyticsCoreAssembly(coreAssembly: coreAssembly)
        let eventQueueAssembly = EventQueue2Assembly(
            stack: stack,
            coreAssembly: coreAssembly,
            analyticsCoreAssembly: analyticsCoreAssembly
        )
        
        self.init(
            coreAssembly: coreAssembly,
            analyticsCoreAssembly: analyticsCoreAssembly,
            eventQueueAssembly: eventQueueAssembly
        )
    }
}
