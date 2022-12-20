//
//  AnalyticsAssembly.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 29/06/2022.
//

import Foundation
import PaltaLibCore
import PaltaLibAnalyticsModel

final class AnalyticsAssembly {
    let coreAssembly: CoreAssembly
    let analyticsCoreAssembly: AnalyticsCoreAssembly
    let eventQueueAssembly: EventQueueAssembly
    
    init(
        coreAssembly: CoreAssembly,
        analyticsCoreAssembly: AnalyticsCoreAssembly,
        eventQueueAssembly: EventQueueAssembly
    ) {
        self.coreAssembly = coreAssembly
        self.analyticsCoreAssembly = analyticsCoreAssembly
        self.eventQueueAssembly = eventQueueAssembly
    }
}

extension AnalyticsAssembly {
    convenience init(stack: Stack) throws {
        let coreAssembly = CoreAssembly()
        let analyticsCoreAssembly = AnalyticsCoreAssembly(coreAssembly: coreAssembly)
        let eventQueueAssembly = try EventQueueAssembly(
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
