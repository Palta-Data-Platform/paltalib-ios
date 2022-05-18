//
//  AnalyticsAssembly.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 11.04.2022.
//

import Foundation
import PaltaLibCore

protocol EventQueueAssemblyProvider {
    func newEventQueueAssembly() ->  EventQueueAssembly
}

final class AnalyticsAssembly: EventQueueAssemblyProvider {
    let coreAssembly = CoreAssembly()

    private(set) lazy var analyticsCoreAssembly = AnalyticsCoreAssembly(coreAssembly: coreAssembly)

    func newEventQueueAssembly() ->  EventQueueAssembly {
        .init(
            coreAssembly: coreAssembly,
            analyticsCoreAssembly: analyticsCoreAssembly
        )
    }
}
