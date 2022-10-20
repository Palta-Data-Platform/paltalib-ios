//
//  BatchMock.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 20/10/2022.
//

@testable import PaltaLibAnalytics

extension Batch {
    static func mock() -> Batch {
        Batch(events: [.mock()], telemetry: .mock())
    }
}
