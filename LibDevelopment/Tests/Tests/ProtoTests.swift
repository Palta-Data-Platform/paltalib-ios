//
//  ProtoTests.swift
//  PaltaLibCore
//
//  Created by Vyacheslav Beltyukov on 14/06/2022.
//

import Foundation
import XCTest
import AnalyticsDTOExample
import PaltaLibCore
@testable import PaltaLibAnalytics

final class ProtoTests: XCTestCase {
    func testSend() {
        let assembly = EventQueue2Assembly(
            stack: .default,
            coreAssembly: CoreAssembly(),
            analyticsCoreAssembly: AnalyticsCoreAssembly(coreAssembly: CoreAssembly())
        )
        
        assembly.eventQueueCore.config = .init(maxBatchSize: 10, uploadInterval: 5, uploadThreshold: 5, maxEvents: 5)
        
        assembly.eventQueue.logEvent(
            PageOpenEvent(
                header: .init(pora: .init(designID: "")),
                pageID: "",
                title: ""
            ),
            outOfSession: false
        )
        let exp = expectation(description: "Finished")
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 60) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2000000)
    }
}
