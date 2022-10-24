//
//  BatchMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 20/10/2022.
//

import Foundation
@testable import PaltaLibAnalytics

extension Batch {
    static func mock() -> Batch {
        Batch(batchId: UUID(), events: [.mock()], telemetry: .mock())
    }
}
