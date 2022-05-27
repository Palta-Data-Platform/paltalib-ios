//
//  EventQueueAssemblyProviderMock.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 18/05/2022.
//

import Foundation
import PaltaLibCore
@testable import PaltaLibAnalytics

final class EventQueueAssemblyProviderMock: EventQueueAssemblyProvider {
    func newEventQueueAssembly() -> EventQueueAssembly {
        .init(coreAssembly: .init(), analyticsCoreAssembly: .init(coreAssembly: .init()))
    }
}
