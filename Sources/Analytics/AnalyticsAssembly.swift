//
//  AnalyticsAssembly.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 11.04.2022.
//

import Foundation
import PaltaLibCore

protocol EventQueueAssemblyProvider {
    func newEventQueueAssembly() throws ->  EventQueueAssembly
}

final class AnalyticsAssembly: EventQueueAssemblyProvider {
    let coreAssembly: CoreAssembly
    let analyticsCoreAssembly: AnalyticsCoreAssembly
    
    init() {
        let coreAssembly = CoreAssembly()
        self.coreAssembly = coreAssembly
        self.analyticsCoreAssembly = AnalyticsCoreAssembly(coreAssembly: coreAssembly)
    }

    func newEventQueueAssembly() throws ->  EventQueueAssembly {
        try .init(
            coreAssembly: coreAssembly,
            analyticsCoreAssembly: analyticsCoreAssembly
        )
    }
}
