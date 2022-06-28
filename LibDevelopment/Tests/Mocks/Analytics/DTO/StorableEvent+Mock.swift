//
//  StorableEvent+Mock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 27/06/2022.
//

import Foundation
@testable import PaltaLibAnalytics

extension StorableEvent {
    static func mock(timestamp: Int = 0, contextId: UUID = UUID()) -> StorableEvent {
        var batchEvent = BatchEventMock()
        batchEvent.timestamp = timestamp
       
        return StorableEvent(
            event: IdentifiableEvent(id: UUID(), event: batchEvent),
            contextId: contextId
        )
    }
}
